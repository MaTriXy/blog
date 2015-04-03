---
layout: post
title: "Custom Drawables"
date: 2015-04-03 12:41:51 -0500
comments: true
categories: 
 - Android
published: true
---
We've all seen posts about why you should use [custom views](/blog/2014/05/14/using-custom-compound-views-in-android/) when applicable and how it can help you properly encapsulate your application code.  What we don't see quite as much is how this type of thinking can be translated to other, non-View related, portions of our apps.

In my app, [Fragment](https://play.google.com/store/apps/details?id=com.pixite.fragment&referrer=utm_source%3Dryanharter.com%26utm_medium%3Dpost%26utm_content%3Dcustom_drawables), there are a few places where I make use of custom Drawables to encapsulate my logic just like you would for a custom View.

<!-- more -->

{% note TLDR %}
This code is a <a href="https://gist.github.com/rharter/34051da57f8a6a0991ff">Gist</a>!
{% endnote %}

## The Use Case

In Fragment, there are a couple of places where we use horizontal scrollers as a selection view. This means that the center icon is the "selected" icon, and items should transition in and out of this state fluidly. For this we decided that a nice reveal transition would be great.

{% img center /images/posts/custom-drawables/example.gif %}

While this wasn't entirely necessary, I felt that it was a effect that made the motion feel very fluid and added a touch of class to the app.  I could have set up multiple image views and make parts of them individual, but this was the perfect place for a custom drawables.

## Customizing Drawables

Drawables in Android are actually very similar to Views. They have similar methods for things like padding and bounds (layout), and have a draw method that can be overridden. In my case, I needed to be able to transition between two drawables, a selected drawable and an unselected drawable, based on a value.

In our case, we simply create a subclass of Drawable that contains other Drawables (and an orientation).

```java
public class RevealDrawable extends Drawable {
  public RevealDrawable(Drawable unselected, Drawable selected, int orientation) {
    this(null, null);

    mUnselectedDrawable = unselected;
    mSelectedDrawable = selected;
    mOrientation = orientation;
  }
}
```

Next we need to be able to set the value identifying where the drawable is in the selection process. Fortunately Drawable has a facility for this type of thing built in, [setLevel(int)](https://developer.android.com/reference/android/graphics/drawable/Drawable.html#setLevel%28int%29).

A Drawable's level is an integer between 0 and 10,000 which simply allows the Drawable to customize it's view based on a value. In our case, we can simply define 5,000 as the selected state, 0 and entirely unselected to the left, and 10,000 as entirely unselected to the right.

All we need to do now is to override the `draw(Canvas canvas)` method to draw the appropriate drawable by clipping the canvas based on the current level.

```java
@Override
public void draw(Canvas canvas) {

  // If level == 10000 || level == 0, just draw the unselected image
  int level = getLevel();
  if (level == 10000 || level == 0) {
    mRevealState.mUnselectedDrawable.draw(canvas);
  }

  // If level == 5000 just draw the selected image
  else if (level == 5000) {
    mRevealState.mSelectedDrawable.draw(canvas);
  }

  // Else, draw the transitional version
  else {
    final Rect r = mTmpRect;
    final Rect bounds = getBounds();

    { // Draw the unselected portion
      float value = (level / 5000f) - 1f;
      int w = bounds.width();
      if ((mRevealState.mOrientation & HORIZONTAL) != 0) {
        w = (int) (w * Math.abs(value));
      }
      int h = bounds.height();
      if ((mRevealState.mOrientation & VERTICAL) != 0) {
        h = (int) (h * Math.abs(value));
      }
      int gravity = value < 0 ? Gravity.LEFT : Gravity.RIGHT;
      Gravity.apply(gravity, w, h, bounds, r);

      if (w > 0 && h > 0) {
        canvas.save();
        canvas.clipRect(r);
        mRevealState.mUnselectedDrawable.draw(canvas);
        canvas.restore();
      }
    }

    { // Draw the selected portion
      float value = (level / 5000f) - 1f;
      int w = bounds.width();
      if ((mRevealState.mOrientation & HORIZONTAL) != 0) {
        w -= (int) (w * Math.abs(value));
      }
      int h = bounds.height();
      if ((mRevealState.mOrientation & VERTICAL) != 0) {
        h -= (int) (h * Math.abs(value));
      }
      int gravity = value < 0 ? Gravity.RIGHT : Gravity.LEFT;
      Gravity.apply(gravity, w, h, bounds, r);

      if (w > 0 && h > 0) {
        canvas.save();
        canvas.clipRect(r);
        mRevealState.mSelectedDrawable.draw(canvas);
        canvas.restore();
      }
    }
  }
}
```

With that, we can simply set the level of the icon based on scroll position and away we go.

```java
float offset = getOffestForPosition(recyclerView, position);
if (Math.abs(offset) <= 1f) {
  holder.image.setImageLevel((int) (offset * 5000) + 5000);
} else {
  holder.image.setImageLevel(0);
}
```

If you'd like to see the source for this custom drawable, you can find the Gist on Github [here](https://gist.github.com/rharter/34051da57f8a6a0991ff)