---
layout: post
title: "Building Dynamic Custom Views"
date: 2014-08-27 16:42
comments: true
categories: 
published: false
---
Last week I released [Fragment][1] for Android.  Fragment is made up of all sorts of custom Views, which I think sets it apart from many apps in the Play Store.  

Some of these views have a similar pattern to views I've had to create for other apps, in which a scroll view has padding such that every item within it can be scrolled to the center of the view.  On it's surface this doesn't seem complex, but when you consider the massive difference in screen sizes available on Android, things get a little more complicated.

# The Control

Lets start by defining our end goal.  The control we want to build allows the user to scroll a view such that any of the contents can be moved to the center of the screen.  Here's an animation demonstrating what I mean.

{% img center /images/posts/building-dynamic-custom-views/control.gif %}

This control, boiled down, is really just a HoriztonalScrollView.  Notice how, when the user scrolls to the end, there is a nice overscroll indicator.  When the user flings the control, it moves accordingly.  The control nicely decelerates just like all other Android ScrollViews, making it feel natural to the user.  These are all things you get for free by subclassing a build in Android widget.

<!-- more -->

This view does, however, pose two challenges.  First, we need enough padding on each side of the view so that the contents will scroll far enough that the edges align with the center of the screen.  Second, we need the ScrollView to be observable, so we can update our value whenever the user scrolls teh view.  Let's tackle these one at a time below.

# An Observable ScrollView

Let's tackle the second issue first, since it's actually quite simple.  We need to be able to observe our HorizontalScrollView, though the orientation isn't exactly relevant, to know when the scroll position changes.

This is a surprizingly simple problem, and I'm always surprized when I'm reminded that this feature isn't built into the default Android ScrollView class.  ListView has a listener interface to be notified with the scroll position changes, so why not ScrollView.  Let's just assume that the AOSP developers figured it was too easy to be required.

While the built in ScrollView classes don't have an OnScrollChangedListener interface, they do have a protected `onScrollChanged` method, so we can easily just subclass the ScrollView of our choosing and create our own interface.  Here's what mine looks like.

```java
package com.ryanharter.android.example;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.HorizontalScrollView;

/**
 * A {@link HorizontalScrollView} with an {@link OnScrollChangedListener} interface
 * to notify listeners of scroll position changes.
 */
public class ObservableHorizontalScrollView extends HorizontalScrollView {
  
  /**
   * Interface definition for a callback to be invoked with the scroll
   * position changes.
   */
  public interface OnScrollChangedListener {
    /**
     * Called when the scroll position of <code>view</code> changes.
     *
     * @param view The view whose scroll position changed.
     * @param l Current horizontal scroll origin.
     * @param t Current vertical scroll origin.
     */ 
    void onScrollChanged(ObservableHorizontalScrollView view, int l, int t);
  }

  private OnScrollChangedListener mOnScrollChangedListener;

  public ObservableHorizontalScrollView(Context context) {
    super(context);
  }

  public ObservableHorizontalScrollView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public ObservableHorizontalScrollView(Context context, AttributeSet attrs, int defStyle) {
    super(context, attrs, defStyle);
  }

  public void setOnScrollChangedListener(OnScrollChangedListener l) {
    mOnScrollChangedListener = l;
  }

  @Override protected void onScrollChanged(int l, int t, int oldl, int oldt) {
    super.onScrollChanged(l, t, oldl, oldt);
    if (mOnScrollChangedListener != null) {
      mOnScrollChangedListener.onScrollChanged(this, l, t);
    }
  }
}
```

As you can see, the only thing that I've added here is the `OnScrollChangedListener` interface, and called it when the ScrollView's position changes.  This is a super simple subclass that adds immense value to the built in ScrollView classes.  

Here's an example of how you might use this.

```java
private OnScrollChangedListener mListener = new OnScrollChangedListener() {
  @Override public void onScrollChanged(ObservableHorizontalScrollView view, int l, int t) {
    // eg. 0.5 = 50 / 100;
    float value = (float) l / view.getMaxScrollAmount();

    // do something with value
  }
}
```

This simple solution gets us exactly what we want, and doesn't take all that much effort to implement.  Aside from the class name, I think it even fits very nicely in with the other Android API classes.

Where did I come up with this elegant solution, you ask?  While I've pointed out several times that this is a very simple solution, the idea for how to approach the problem actually came from a piece of [open source code][2] that I saw a while back.  This is why it pays to be involved in open source, even if it's just diving through the code of others.

# Dynamic Padding

The other challenge that we identified when making this view was that the scrolling contents needs to be able to be in the center of the screen.  The challenge here is that we don't know the width of the screen at compile time, and can't even get the width of the view until it is measured, so we need a dynamic way to add spacing around the scrolling content.

## OnPreDrawListener

One way we can achieve this is by using the `ViewTreeObserver`'s [OnPreDrawListener][3].  This is a super handy callback which is called before our views are drawn but after they have been measured.  This allows us to modify our views (add spacers) once we know the size of the view.  Here's an example:

```java
scrollView.getViewTreeObserver().addOnPreDrawListener(new OnPreDrawListener() {
  @Override public boolean onPreDraw() {
    // Be sure to remove the listener, or it will be called on every draw pass
    scrollView.getViewTreeObserver().removeOnPreDrawListener(this);

    LinearLayout child = (LinearLayout) scrollView.getChildAt(0);

    // Create LayoutParams for the spacers that are half the width of the ScrollView.
    int width = scrollView.getWidth();
    LinearLayout.LayoutParams p = 
        new LinearLayout.LayoutParams(width / 2, LinearLayout.LayoutParams.MATCH_PARENT);

    // Add the left spacer (blank view)
    View leftSpacer = new View(getContext());
    leftSpacer.setLayoutParams(p);
    child.addView(leftSpacer, 0);

    // Add the right spacer (blank view);
    View rightSpacer = new View(getContext());
    rightSpacer.setLayoutParams(p);
    child.addView(rightSpacer);

    // Return false so that the View doesn't get drawn, and does a new layout pass with
    // our new spacer views.
    return false;
  }
});
```

What this does is add invisible spacer views to the front and the back of the child content, allowing the appearance of the child content scrolling to the center of the view.  Here's a diagram showing what I mean.

{% img center /images/posts/building-dynamic-custom-views/scrolling-diagram-1.png %}

You can see here that there is really never any empty space in the ScrollView, we just make it appear that way with empty views.

This is a nice approach because it can be added onto any ScrollView in the code, without modifying your existing layouts (assuming the child of the ScrollView is a LinearLayout appropriately oriented).  Throw this in a view helper and it can be as simple as `ViewHelper.addScrollingSpacers(scrollView);`.

One downside of this approach is that we actually throw away a layout-measure-draw cycle.  Remember that our OnPreDrawListener is called at the end of this cycle so that we know the width of our ScrollView.  That means that the first time around, this is really a layout-measure-add-spacers-layout-measure-draw cycle.  At the end of the day, since this only happens once, it's not generally a big deal, but it is something to note.

But what if there was a way to add our spacers earlier in the layout-measure-draw cycle?

## onLayout

As it would happen, there is.  Since we want to modify the layout of the items, with a [custom compound view][4] we can make our adjustments **during** the layout cycle, meaning no wasted time.  Here's how we might accomplish that.

```java
public class ScrollingValuePicker extends FrameLayout {
  
  private View mLeftSpacer;
  private View mRightSpacer;
  private ObservableHorizontalScrollView mScrollView;

  public ScrollingValuePicker(Context context) {
    this(context, null);
  }

  public ScrollingValuePicker(Context context, AttributeSet attrs) {
    this(context, attrs, 0);
  }

  public ScrollingValuePicker(Context, context, AttributeSet attrs, int defStyle) {
    super(context, attrs, defStyle);

    // Create our internal scroll view
    mScrollView = new ObservableHorizontalScrollView(context);
    mScrollView.setHorizontalScrollBarEnabled(false);
    addView(mScrollView);

    // Create a horizontal (by default) LinearLayout as our child container
    final LinearLayout container = new LinearLayout(context);
    mScrollView.addView(container);

    // Our actual content is an ImageView, but doesn't need to be
    final ImageView sliderBg = new ImageView(context);
    sliderBg.setImageResource(R.drawable.scrolling_slider_bg);
    sliderBg.setAdjustViewBounds(true);
    container.addView(sliderBg);

    // Create the left and right spacers, don't worry about their dimesnions, yet.
    mLeftSpacer = new View(context);
    container.addView(mLeftSpacer, 0);

    mRightSpacer = new View(context);
    container.addView(mRightSpacer);
  }

  @Override protected void onLayout(boolean changed, int l, int t, int r, int b) {
    super.onLayout(changed, l, t, r, b);

    if (changed) {
      // Layout the spacers now that we are measured
      final int width = getWidth();

      final ViewGroup.LayoutParams leftParams = mLeftSpacer.getLayoutParams();
      leftParams.width = width / 2;
      mLeftSpacer.setLayoutParams(leftParams);

      final ViewGroup.LayoutParams rightParams = mRightSpacer.getLayoutParams();
      rightParams.width = width / 2;
      mRightSpacer.setLayoutParams(rightParams);
    }
  }

  // do stuff with the scroll listener we created early to make our values usable.
}
```

In this example, you can see that our custom compound view is really the container of an ObservableHorizontalScrollView, and that it sets the spacer width whenever the layout changes, during the initial layout pass.

This approach also makes our view easily reusable via our XML layouts, like so:

```xml
<com.ryanharter.android.example.ScrollingValuePicker
  android:id="@+id/myScrollingValuePicker"
  android:layout_width="match_parent"
  android:layout_height="wrap_content" />
```

# The End

You now have a few different ways to create a custom view that will delight your users.  Which one you choose is entirely up to you, but both can be extended to work with ListViews, or really any scrolling view to which you would like some extra space.

These techniques can be used for other effects, as well.  For instance, in addition to using this for custom value selectors, I've used the same approach for things like [parallax effects][5].

There's just another couple of tools for your toolbelt.  If you've done something similar to this, or have another approach, share it in the comments.


[1]: http://fragmentapp.com
[2]: https://code.google.com/p/romannurik-code/source/browse/misc/scrolltricks/src/com/example/android/scrolltricks/ObservableScrollView.java?r=87d727550384ed29bc6eda7181ce7cdee8a2bb9f
[3]: https://developer.android.com/reference/android/view/ViewTreeObserver.OnPreDrawListener.html
[4]: /blog/2014/05/14/using-custom-compound-views-in-android/
[5]: https://play.google.com/store/apps/details?id=com.fxnetworks.fxnow&hl=en