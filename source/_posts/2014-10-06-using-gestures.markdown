---
layout: post
title: "Using Gestures"
date: 2014-10-08 10:42
comments: true
categories: 
 - Android
 - Tips
 - Tutorials
published: true
---
{% img center /images/posts/gestures/header.png %}

Modern Android apps often make use of gesture interaction to provide fluid, natural interaction with the app.  There are a few ways to handle these interactions, and in this post I'm going to cover some of the basics for easily adding gesture support to your app.

<!-- more -->

The code for this sample app can be found at [Github][0].

The basic building blocks of this simple gesture handling code is the [GestureDetector][1], and the various [OnGestureListeners][2].  These classes allow you to easily detect and handle certain gestures, whithout having to worry about tracking touch events and determine the math to decide what type of gesture it is.

# The Gesture Detector

The [GestureDetector][1] is a class that monitors touch events to determine when they adhere to a specified gesture, and converts those touches into meaningful data.  In the sample code, we're going to be using a [ScaleGestureDetector][3] in particular, but they generally all work the same.

The basic idea of a GestureDetector is to read your view's MotionEvents, which you've captured by either overriding the `onTouchEvent(MotionEvent event)` method or by adding a [View.OnTouchListener][4] to your view, and passing data interpereted from those touches to a Listener if they match the desired gesture.

# The Gesture Listener

The [OnGestureListener][2] is called whenever the gesture has been triggered, to allow you to handle that gesture however you see fit.  By the time the OnGestureListener is called, the gesture has been translated into meaningful data, like a scroll delta or a scale factor, so you don't need to do the math and touch tracking yourself.

This makes it very easy to add simple gesture support to your app, without having to track touches and deltas yourself.  Let's take a look at an example.

# The Example

In our example, we'll be creating simple app that displays an image, and allows the user to scale the image using the standard pinch gesture.

To accomplish this, we'll be creating a very simple `ImageView` subclass, called `TouchImageView`, and overriding the `onTouchEvent(MotionEvent)` method.

```java
public class TouchImageView extends ImageView
        implements ScaleGestureDetector.OnScaleGestureListener {

    /** The custom gesture detector we use to track scaling. */
    private ScaleGestureDetector mScaleDetector;

    /** The scale value of our internal image view. */
    private float mScaleValue = 1.0f;

    public TouchImageView(Context context, AttributeSet attrs) {
        super(context, attrs);

        // Set the scale type to MATRIX so that the scaling works.
        setScaleType(ScaleType.MATRIX);

        // Add a scale GestureDetector, with this as the listener.
        mScaleDetector = new ScaleGestureDetector(context, this);
    }

    @Override public boolean onTouchEvent(MotionEvent event) {
        // Pass our events to the scale gesture detector first.
        boolean handled = mScaleDetector.onTouchEvent(event);

        // If the scale gesture detector didn't handle the event,
        // pass it to super.
        if (!handled) {
            handled = super.onTouchEvent(event);
        }

        return handled;
    }

    /*
     * ScaleGestureDetector callbacks
     */
    @Override public boolean onScale(ScaleGestureDetector detector) {
        // Get the modified scale value
        mScaleValue *= detector.getScaleFactor();

        // Set the image matrix scale
        Matrix m = new Matrix(getImageMatrix());
        m.setScale(mScaleValue, mScaleValue);
        setImageMatrix(m);

        return true;
    }

    @Override public boolean onScaleBegin(ScaleGestureDetector detector) {
        // Return true here to tell the ScaleGestureDetector we
        // are in a scale and want to continue tracking.
        return true;
    }

    @Override public void onScaleEnd(ScaleGestureDetector detector) {
        // We don't care about end events, but you could handle this if
        // you wanted to write finished values or interact with the user
        // when they are finished.
    }
}
```

As you can see in the code above, our custom ImageView instantiates a `ScaleGestureDetector` and implements the `ScaleGestureDetector.OnScaleGestureListener` callbacks itself.

The important piece which triggers the gesture detector is the call to `mScaleGestureDetector.onTouchEvent(event)`, which returns true if the gesture is satisfied and the detector will be handling the event.

```java
@Override public boolean onTouchEvent(MotionEvent event) {
    // Pass our events to the scale gesture detector first.
    boolean handled = mScaleDetector.onTouchEvent(event);

    // If the scale gesture detector didn't handle the event,
    // pass it to super.
    if (!handled) {
        handled = super.onTouchEvent(event);
    }

    return handled;
}
```

If the gesture detector doesn't handle the event, then we pass it through to the super class to handle.

When the events constitute a scale gesture (pinch to zoom), the gesture detector will convert that gesture into a scale factor, accessible via `detector.getScaleFactor()`, and pass it to the `onScale(ScaleGestureDetector)` method of the Listener.

```java
@Override public boolean onScale(ScaleGestureDetector detector) {
    // Get the modified scale value
    mScaleValue *= detector.getScaleFactor();

    // Set the image matrix scale
    Matrix m = new Matrix(getImageMatrix());
    m.setScale(mScaleValue, mScaleValue);
    setImageMatrix(m);

    return true;
}
```

This is where we simply set the scale of image using the image matrix.  Most apps would likely do more here, like checking that the scale factor remains within a certain bounds so that the image doesn't get scaled down to nothing, but that's left as an exercise for the reader.

# That's All

That's all there is to this custom view.  With these minor additions, and the help of the [ScaleGestureDetector][3], we were able to add pinch to zoom to a simple ImageView with minimal code.

Extending the gesture support is also easy by simply adding more GestureDetectors.  In [Fragment][5], for instance, we use 3 different GestureDetectors (Translate, Scale, Rotate) on the same view to achieve the smooth, gesture based editing.

You can also check out the [Android Gesture Detectors][6] project on Github for some more Gesture Detectors that work with multi touch gestures.  (I didn't write that library, just converted it to Gradle and deployed it to Maven Central.  I've got a PR out to the owner to merge those in and upload to his own Maven Central groupId.)



[0]: https://github.com/rharter/android-gesture-sample
[1]: https://developer.android.com/reference/android/view/GestureDetector.html
[2]: https://developer.android.com/reference/android/view/GestureDetector.OnGestureListener.html
[3]: https://developer.android.com/reference/android/view/ScaleGestureDetector.html
[4]: http://developer.android.com/reference/android/view/View.OnTouchListener.html
[5]: https://play.google.com/store/apps/details?id=com.pixite.fragment
[6]: https://github.com/rharter/android-gesture-detectors