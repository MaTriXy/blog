---
layout: post
title: "Styling Chromecast Icons"
date: 2015-03-06 09:05:47 -0600
comments: true
categories: 
published: true
---
{% img center /images/posts/chromecast-icons/header.png %}

One of my favorite new devices from Google is the Chromecast. I have 3 throughout my house, and one for travel. It's great to have a cheap device that anyone can stream to.

I've also had the pleasure of integrating Google Cast support on several apps in my [freelancing business](http://analog-ocean.com).  These are usually pretty cut and dry, but I recently had a client who needed a custom Google Cast action item which was one of many colors, depending on where you are in the app.

{% img center /images/posts/chromecast-icons/icons.jpg %}

This makes for a really cool user experience, but isn't exactly straight forward using the media support libraries. Below, I'll walk you through the common solution to this, and how I was able to support truly custom colors throughout my app.

{% note tl;dr %}
You can check out the final solution in this <a href="https://gist.github.com/rharter/c2787f9ddd32651e8885">Gist</a>. Though there are several parts to it, so come back here if you need some more context.
{% endnote %}

# The MediaRouteActionProvider

First, lets talk about how the Google Cast action item is displayed on the screen. You might think that the cast icon you see in the toolbar is simply another icon, but it's much more than that.

Think about everything the cast icon has to do. It has to convey the state of the Google Cast connection, showing no icon when no Google Cast devices are available, showing a connected or disconnected icon, or showing an animated icon while connecting to a device. In addition to just showing current state, when the user taps the icon different things happen depending on that state.

To include all of that logic everywhere you see the cast icon (usually every activity), Google has encapsulated it nicely into an [ActionProvider](https://developer.android.com/reference/android/view/ActionProvider.html), specifically [MediaRouteActionProvider](https://developer.android.com/reference/android/app/MediaRouteActionProvider.html).

From a development perspective, this is great, as I don't want to spend my time worrying about all of these little details. Unfortunately, this also means that customizing that icon isn't quite as easy as replacing a drawable.

# Common Styling Mechanisms

Current [solutions](http://stackoverflow.com/questions/19278319/how-do-i-change-the-style-of-the-mediaroutebutton-in-the-actionbar) online tend to involve replacing the drawables that the support library uses draw the icon. This works in some cases, but falls apart when you need any more than two colors (light and dark). In the past I would have considered that a ridiculous requirement, but, particularly with the new Material design push, using color for your branding and identity adds a whole new dimension to your app. And in some apps, like sports apps, having sections of the app have entirely different color palettes really adds a personal touch to delight the user.

Android has great style and theme support built in, so why doesn't this portion of the support library make better use of that?

# The Support Library Implementation

If, like me, you immediately dive into the library source code to look for a good way to solve problems, you will have discovered some very promising comments, like this one from [MediaRouteActionProvider](https://android.googlesource.com/platform/frameworks/support/+/master/v7/mediarouter/src/android/support/v7/app/MediaRouteActionProvider.java#234).

```java
/**
 * Called when the media route button is being created.
 * <p>
 * Subclasses may override this method to customize the button.
 * </p>
 */
public MediaRouteButton onCreateMediaRouteButton() {
    return new MediaRouteButton(getContext());
}
```

Well that looks great, especially since the constructor for [MediaRouteButton](https://android.googlesource.com/platform/frameworks/support/+/master/v7/mediarouter/src/android/support/v7/app/MediaRouteButton.java#121) uses the style attribute `externalRouteEnabledDrawable` to set the icon.  That means that styling the icon is as simple as creating a different theme resource for each Activity that needs a different color, and overriding the `externalRouteEnabledDrawable` value with our custom icon.  Time to tell the client it'll be a 15 minute fix and ship it, right?

After finding this to mysteriously not work as expected, I looked a little closer and noticed this: `super(MediaRouterThemeHelper.createThemedContext(context, false), attrs, defStyleAttr);`.  If you take a closer look at [MediaRouterThemeHelper](https://android.googlesource.com/platform/frameworks/support/+/master/v7/mediarouter/src/android/support/v7/app/MediaRouterThemeHelper.java), you'll find this:

```java
public static Context createThemedContext(Context context, boolean forceDark) {
    boolean isLightTheme = isLightTheme(context);
    if (isLightTheme && forceDark) {
        context = new ContextThemeWrapper(context, R.style.Theme_AppCompat);
        isLightTheme = false;
    }
    return new ContextThemeWrapper(context, isLightTheme ?
            R.style.Theme_MediaRouter_Light : R.style.Theme_MediaRouter);
}
```

It turns out that the theme is being set to one of two static values in the `MediaRouteButton` constructor. In most cases this probably isn't an issue, but in my case, where I need the icon to be more than one of two different colors, this just doesn't work.

This explains why the existing solutions involve simply creating a drawable resource with the same name as the one referenced by these styles, so that Gradle will overwrite it when you build your app. This is a poor solution that doesn't make good use of Android's excellent styling support.

# My Solution

Since the `mRemoteIndicator` has private access in the MediaRouteButton, my only course of action was to subclass the support library's implementation, and replace every reference to that Drawable with my own. To take it a step further, and relieve some strain from my designers, I decided that setting the color in the style, as opposed to using a different drawable for every item, made a lot of sense.

The first step was to create a custom [ThemeableMediaRouteButton](https://gist.github.com/rharter/c2787f9ddd32651e8885#file-themeablemediaroutebutton-java). I simply subclassed the support library's `MediaRouteButton`, and replaced all references to `mRemoteIndicator` drawable with my own. This basically amounted to a lot of copying and pasting.

```java
public class ThemeableMediaRouteButton extends MediaRouteButton {
 
  ...

  public ThemeableMediaRouteButton(Context context, AttributeSet attrs, int defStyleAttr) {
      super(context, attrs, defStyleAttr);

      TypedArray a = context.obtainStyledAttributes(attrs,
              R.styleable.ThemeableMediaRouteButton, defStyleAttr, 0);
      mColor = a.getColor(R.styleable.ThemeableMediaRouteButton_iconColor, 0);
      setRemoteIndicatorDrawable(a.getDrawable(
              R.styleable.ThemeableMediaRouteButton_routeEnabledDrawable));
      mMinWidth = a.getDimensionPixelSize(
              R.styleable.ThemeableMediaRouteButton_android_minWidth, 0);
      mMinHeight = a.getDimensionPixelSize(
              R.styleable.ThemeableMediaRouteButton_android_minHeight, 0);

      a.recycle();
  }

  ...

  private void setRemoteIndicatorDrawable(Drawable d) {
      if (mRemoteIndicator != null) {
          mRemoteIndicator.setCallback(null);
          unscheduleDrawable(mRemoteIndicator);
      }
      mRemoteIndicator = d;
      if (d != null) {
          d.setColorFilter(mColor, PorterDuff.Mode.SRC_ATOP);
          d.setCallback(this);
          d.setState(getDrawableState());
          d.setVisible(getVisibility() == VISIBLE, false);
      }

      refreshDrawableState();
  }
}
```

Notice how I use a `setColorFilter` on the drawable to color it using the `iconColor` attribute.

As we saw from the comments in `MediaRouteActionProvider`, we know exactly what to change in our [subclass](https://gist.github.com/rharter/c2787f9ddd32651e8885#file-themeablemediarouteactionprovider-java) to return our custom button.

```java
public class ThemeableMediaRouteActionProvider extends MediaRouteActionProvider {
 
    public ThemeableMediaRouteActionProvider(Context context) {
        super(context);
    }
 
    @Override public MediaRouteButton onCreateMediaRouteButton() {
        return new ThemeableMediaRouteButton(getContext());
    }
}
```

As you can see, I'm relying on some styles from a styleable resource, so that needs to be declared in my [attrs.xml](https://gist.github.com/rharter/c2787f9ddd32651e8885#file-attrs-xml) file.

```xml
<resources>
    <declare-styleable name="ThemeableMediaRouteButton">
        <!-- This drawable is a state list where the "checked" state
             indicates active media routing.  Checkable indicates connecting
             and non-checked / non-checkable indicates
             that media is playing to the local device only. -->
        <attr name="routeEnabledDrawable" format="reference" />
        <attr name="iconColor" format="reference|color" />
        <attr name="android:minWidth" />
        <attr name="android:minHeight" />
    </declare-styleable>
</resources>
```

The allows me to use [styles](https://gist.github.com/rharter/c2787f9ddd32651e8885#file-styles-xml) and [themes](https://gist.github.com/rharter/c2787f9ddd32651e8885#file-themes-xml) to provide these values.

```xml
<resources>
  <style name="Theme.MyApp">
      <item name="mediaRouteButtonStyle">@style/Widget.MediaRouter.MediaRouteButton</item>
  </style>
  <style name="Theme.MyApp.Section1">
      <item name="mediaRouteButtonStyle">@style/Widget.MediaRouter.MediaRouteButton.Section1</item>
  </style>
  <style name="Theme.MyApp.Section2">
      <item name="mediaRouteButtonStyle">@style/Widget.MediaRouter.MediaRouteButton.Section2</item>
  </style>

  <style name="Widget.MediaRouter.MediaRouteButton" parent="Widget.MediaRouter.Light.MediaRouteButton">
      <item name="routeEnabledDrawable">@drawable/ic_chrome_media_route</item>
      <item name="iconColor">@color/red</item>
  </style>
  <style name="Widget.MediaRouter.MediaRouteButton.Section1">
      <item name="iconColor">@color/white</item>
  </style>
  <style name="Widget.MediaRouter.MediaRouteButton.Section2">
      <item name="iconColor">@color/blue</item>
  </style>
</resources>
```

The last step is to use our custom ActionProvider in the cast menu, this is as simple as replacing the existing menu item with our custom implementation:

```xml
<menu xmlns:android="http://schemas.android.com/apk/res/android"
  xmlns:app="http://schemas.android.com/apk/res-auto" >

  <item
      android:id="@+id/menu_cast_item"
      android:icon="@drawable/ic_chrome_off"
      android:orderInCategory="0"
      app:showAsAction="always"
      app:actionProviderClass="com.ryanharter.mediaroute.widgets.ThemeableMediaRouteActionProvider"
      android:title="@string/menu_cast"/>
</menu>
```

With that, you should now have a fully customized Google Cast icon to fit your app theme.  To see the full solution, check out this [Gist](https://gist.github.com/rharter/c2787f9ddd32651e8885).

# The Ideal Solution

Ideally the support library would make use of default values, instead of relying on hard coded styles, so that we could easily override the colors of the icon.  That being said, I also understand that the support library has to work easily for 95% of users, so perhaps there are some edge cases that I've overlooked.

All in all, this may not be a super simple solution, but it's a great way to delight users by going that extra mile to create a really unique experience.