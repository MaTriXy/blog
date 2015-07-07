---
layout: post
title: "Wrapping Existing Libraries with RxJava"
date: 2015-07-07 08:55:36 -0500
comments: true
categories: 
published: true
---
[RxJava](https://github.com/ReactiveX/RxJava) is all the rage in the Android world lately, and with good reason. While Functional Reactive Programming has a bit of a steep learning curve, the benefits are enormous.

One issue I've run accross is the fact that I need to use libraries that don't support RxJava, but use the Listener pattern instead, and therefore miss out on many of the composability benefits of Rx.

I ran into this exact issue while [integrating OpenIAB](http://ryanharter.com/blog/2015/07/04/using-all-the-app-stores/) into the latest release of [Fragment](https://play.google.com/store/apps/details?id=com.pixite.fragment).  To make matters more difficult, [OpenIAB](http://onepf.org/openiab/) uses `startActivityForResult` to actually launch a new Activity and return a result. That made me wonder, how can I use OpenIAB with RxJava?

<!-- more -->

## Wrap It Up

The solution here is to wrap the existing library with some Rx. This can seem a little confusing since OpenIAB uses the Listener pattern, and also uses `startActivityForResult`, but is actually quite simple, and the basic rules can apply to any listener based library.

If you've read any of [Dan Lew](http://blog.danlew.net)'s articles in his Grokking RxJava series, you will have probably come accross his mention of handling [Old, Slow Code](http://blog.danlew.net/2014/10/08/grokking-rxjava-part-4/#oldslowcode). He covers wrapping synchronous methods with `Observable.just()`, `Observable.from()` and `Observable.defer()` to create observables, but listener based libraries use listeners because they handle their own threading, and generally don't return a result.

{% note %}
Before we get started wrapping the listener based code with Rx, there is one thing I should point out. If your library has synchronous methods that simply return the result, and don't handle any of the threading themselves, then Dan's method is preferrable. Using the threading support of RxJava mixed with the library's internal threading throughout your app can be confusing and should only be use if necessary.
{% endnote %}

## The API

As an example for wrapping existing libraries in RxJava Observables, I'm going to use OpenIAB, a multi-store in app purchase library that I recently integrated into Fragment.

If you've seen my [talk](https://www.youtube.com/watch?v=VITu_wp4pNc&list=PLqUf0A_J96n7NSfEUMjISZJPH4A-RIhta&index=6) from Droidcon Montreal, you'll know that I like to build libraries from the outside in, so first we need to define our API.

```java
public interface InAppHelper {

  /**
   * Sets up the InAppHelper if it hasn't been already.
   */
  Observable<Void> setup();

  /**
   * Returns the Inventory based on the supplied <code>skus</code>.
   */
  Observable<Inventory> queryInventory(List<String> skus);

  /**
   * Begins the purchase flow for the specified sku.
   */
  Observable<Purchase> purchase(String sku);
}
```

Each of these three method's underlying implementation in OpenIAB works a little bit differently. `setup()` uses a standard Listener callback interface, `queryInventory()` can be done synchronously, but we can't use `Observable.just()` since it throws a non-Runtime Exception which must be caught, and `purchase()` uses a listener, but also relies on `startActivityForResult`.

Let's take each of these one at a time to see how we can wrap each type of method call with an RxJava Observable.

{% note %}
Though I don't use it in production, I'm using Java 8 lambdas in the code examples for brevity. Others do use them in productions using <a href="https://github.com/evant/gradle-retrolambda">Retrolambda</a>, and you're welcome to do that if you wish.
{% endnote %}

## Wrapping Listener Methods in RxJava

When wrapping method calls that use listeners, things like `Observable.just()` don't work, since there is usually no return value. Therefore, we have to use `Observable.create()` so that we can pass the result of the Listener callback to the subscriber.

```java
public Observable<Object> wrappedListener() {
  return Observable.create((subscriber) -> {
    helper.listenerMethod((result) -> {
        if (result.isSuccess()) {
          subscriber.onNext(result.getData());
          subscriber.onCompleted();
        } else {
          subscriber.onError(result.getError());
        }
      }
    });
  });
}
```

To take this step by step, you can see in the `wrappedListener()` method that we are using `Observable.create()` to create an Observable, and in the `OnSubscribe` block we call our listener based method, **providing our own Listener implementation** that passes results to the subscriber accordingly.

In our OpenIAB example, this method looks like this:

```java
public Observable<Void> setup() {
  return Observable.create((subscriber) -> {
    if (!helper.setupSuccessful()) {
      helper.startSetup((result) -> {
        if (result.isSuccess()) {
          subscriber.onNext(null);
          subscriber.onCompleted();
        } else {
          subscriber.onError
        }
      });
    } else {
      subscriber.onNext(null);
      subscriber.onComplete();
    }
  });
}
```

As you can see, we call the `iabHelper.startSetup()` method inside our OnSubscribe class, passing our own `OnIabSetupFinishedListener` implementation that passes the result to the subscriber accordingly.

Notice that we can easily bypass the asynchronous call if the helper is already set up.

## Wrapping Synchronous Methods That Throw Exceptions

The second method we have to implement, `queryInventory()`, can be done as a synchronous call, but we can't use `Observable.create()` because the `IabException` it throws isn't a `RuntimeException`, so it must be caught.

To accomplish this, we take a very similar approach as before, using `Observable.onCreate()`, but we simply return the result, and handle the exception accordingly.

```java
public Observable<Object> wrappedThrower() {
  return Observable.create((subscriber) -> {
    try {
      subscriber.onNext(helper.methodThatThrows());
      subscriber.onCompleted();
    } catch (Exception e) {
      subscriber.onError(e);
    }
  });
}
```

This is a pretty simple case. One thing to note is that calling `subscriber.onError()` might not be the best approach. If the exception is recoverable, then you should call `subscriber.onNext()` with some other value. Remember, `onError()` should only be called when the subscription is no longer usable.

In our OpenIAB library, this solution looks like this:

```java
public Observable<Inventory> queryInventory(final List<String> skus) {
  return Observable.create((subscriber) -> {
    try {
      subscriber.onNext(helper.queryInventory(skus));
      subscriber.onCompleted();
    } catch (IabException e) {
      subscriber.onError(e);
    }
  });
}
```

## Wrapping Methods That User Listeners and Activity Results

The last method we need to implement, `purchase()`, is the same as the Listener example above, but it has the added complexity of using `startActivityForResult`. Since this is also using a Listener, this doesn't really change our Observable implementation, we just need to add a method on our Helper interface so that we can pass the activity result through.

Since this is just about the same as our original Listener example, we'll go straight to the OpenIAB implementation.

```java
public Observable<Purchase> purchase(final String sku) {
  return Observable.create((subscriber) -> {
    helper.launchPurchaseFlow(activity, sku, REQUEST_CODE_PURCHASE, (result, info) -> {
      if (result.isSuccess() || result.getResponse() == IabHelper.BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED) {
        subscriber.onNext(info);
        subscriber.onCompleted();
      } else {
        subscriber.onError(new InAppHelperException(result.getMessage()));
      }
    });
  });
}

public boolean handleActivityResult(int requestCode, int resultCode, Intent data) {
  return helper.handleActivityResult(requestCode, resultCode, data);
}
```

As you can see, our `handleActivityResult()` method simply passed the result through to the IabHelper to handle. If the activity result matches our request, the Listener we created will be called, which in turn calls our subscriber methods.

## Rx Everywhere

These are just a few examples showing how to wrap existing libraries in RxJava. That should help you consistently use Functional Reactive Programming throughout your Android apps, and take advantage of some of the many benefits.

After some cleanup, I'll get the full code to my RxOpenIAB wrapper on Github for you to see.