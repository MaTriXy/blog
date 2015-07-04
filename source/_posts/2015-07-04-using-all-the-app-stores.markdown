---
layout: post
title: "Using All the App Stores"
date: 2015-07-04 09:01:37 -0500
comments: true
categories: 
published: true
---
Shortly after our initial release of the Pack Store in [Fragment](https://play.google.com/store/apps/details?id=com.pixite.fragment) earlier this year, other companies started contacting us wanting Fragment on their App stores, as well.  With the addition of the Pack Store, and in app purchases, this made things challenging.

When I first implemented the Pack Store, I used [Sergey Solovyev](https://github.com/serso)'s excellent [Android Checkout](https://github.com/serso/android-checkout) library to implement the In App Billing support.  This is a great library that eased a lot of the pain of the IAB implementation, but tightly coupled Fragment with the Google Play Store.

In order to release with more stores and partners, I needed a more open solution. As the developer of Fragment, and the person that has to manage builds and releases, I wanted to avoid having multiple build flavors to cover all the stores, since that would quickly get unweildy. My search for a more open IAB solution led me to [OpenIAB](http://onepf.org/openiab/).

<!-- more -->

## OpenIAB

OpenIAB is a library from the One Platform Foundation designed for exactly this purpose. They've abstracted the different store implentations so that you can use one build with all the stores. This means I don't have to manage a different build for each store we want to release on.

For it's API, it uses the familiar [IabHelper](https://code.google.com/p/marketbilling/source/browse/v3/src/com/example/android/trivialdrivesample/util/IabHelper.java) architecture from Google's TrivialDrive sample. This makes migration easy, whether you're coming from another library like Android-Checkout, or the copy and pasted code from the samples.

While I updated the code, I decided to wrap the implementation with RxJava for convenience. I'll get to more of this in a future post.

After updating the code, you simply need to set up developer accounts on other stores and add your purchasable items.  We chose to go with the [Amazon Appstore](http://www.amazon.com/mobile-apps/b?node=2350149011) as our first additional store, since it's a well known one here in the US, and their [App Tester](http://www.amazon.com/dp/B00BN3YZM2/?tag=googhydr-20&hvadid=73686779225&hvpos=1t1&hvexid=&hvnetw=g&hvrand=8716314708711191863&hvpone=&hvptwo=&hvqmt=e&hvdev=c&ref=pd_sl_63jbhsymab_e) tool makes testing in app purchases remarkably easy.

## Results

For now, Fragment is available on both [Google Play](https://play.google.com/store/apps/details?id=com.pixite.fragment) and the [Amazon Appstore](http://www.amazon.com/Pixite-LLC-Fragment/dp/B010GMJ2GY/ref=sr_1_1?s=mobile-apps&ie=UTF8&qid=1436022164&sr=1-1&keywords=fragment), but we have plans to move to more stores soon. We have yet to see what kind of impact this will have on Fragment's success, but with an easy implementation and broader exposure available to the Android platform, it's an experiment well worth doing. I'll be sure to report back once we have some results.