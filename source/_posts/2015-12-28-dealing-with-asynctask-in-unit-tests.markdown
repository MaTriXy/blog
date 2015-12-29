---
layout: post
title: "Dealing with AsyncTask in Unit Tests"
date: 2015-12-28 18:45:53 -0600
comments: true
categories:
published: true
---
There may be a shortage of love on the internet for [AsyncTasks](https://developer.android.com/reference/android/os/AsyncTask.html), but that doesn't mean they don't have their uses.  I've found myself using them a fair bit in the latest project that I'm working on.  All in all, they make offloading tasks from the main thread quite simple, but can pose some challenges, particularly in tested environments.

The biggest challenge with using AsyncTask in tested code is that, since the code runs asynchronously, it can be difficult to ensure your tests get the right result for verification.  I have seen [some solutions](http://marcouberti.net/2015/07/11/mock-async-task-in-android-during-testing/) for getting around this dilemma, but they involve pretty significant changes to the structure of your app, and exposing some internal members, simply for the sake of the tests.

<!-- more -->

An alternative approach is to simply take advantage of your Android project's source sets.  You can simply create a class with the same name and package as any system class in your test source set, and it will override the system (or any other) class.  So in this case, we simply create a new `android.os.AsyncTask` class in our `src/test` source set, and any references to this class in our code will use our implementation, **only while running tests**.

Here's an example of my `AsyncTask` implementation, which only provides the methods I happen to use for simplicity, and runs the code that would otherwise happen on a background thread synchronously.

```java
package android.os;

/**
 * This is a shadow class for AsyncTask which forces it to run synchronously.
 */
public abstract class AsyncTask<Params, Progress, Result> {

  protected abstract Result doInBackground(Params... params);

  protected void onPostExecute(Result result) {
  }

  protected void onProgressUpdate(Progress... values) {
  }

  public AsyncTask<Params, Progress, Result> execute(Params... params) {
    Result result = doInBackground(params);
    onPostExecute(result);
    return this;
  }
}
```

Now that I have this in my `src/test` source set, any subclass of `android.os.AsyncTask` in my project will actually be subclassing this synchronous implementation only while my tests are running, making my test code much simpler.

## A Few Words of Caution

There are a few thing to watch out for with this approach.

First, be sure that you only do this in your `src/test` source set, as this can cause problems if it makes it's way into your actual app code.  The code in `src/test` won't be compiled into your final APK, so it should be fairly safe, just don't be careless.

Second, once you override a class in a source set, **every** use of it will be replaced with your custom implementation.  This means that you can't replace the implementation of AsyncTask for one test, but use the system implementation for another.  This shouldn't be much of an issue in the `src/test` source set, since system classes don't have implementations anyway, but watch out if you try to use this trick in another environment, like instrumentation tests.

Lastly, and most importantly, when writing test code you want to be sure you aren't introducing bugs through your test code.  If you replace a system class and it behaves differently than the actual implementation, that could effect the validity of your tests.

In this case, the code functionality I'm replacing is fairly simple, so it's not a big deal.  And, fortunately, Android is open source, so you can simply verify your implementation with the [actual source](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/java/android/os/AsyncTask.java) if you have any concerns.
