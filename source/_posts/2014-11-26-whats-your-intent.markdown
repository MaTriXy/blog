---
layout: post
title: "What's Your Intent?"
date: 2014-11-26 13:32:03 -0600
comments: true
categories: 
  - Android
  - Tips
published: true
---
{% img center /images/posts/intents/banner_intents.png %}

One of the most powerful, yet sometimes overlooked, features of Android is the [Intent](https://developer.android.com/reference/android/content/Intent.html) system.  Android's Intents allow apps to interact with each other, without intimate knowledge of each other.

Intents are one of the differentiating factors that allows Android apps to interact and send data beyond their walls, while still keeping the system relatively safe.

<!-- more -->

# Anatomy of an Intent

I like to think of Intents as the opposite of URLs.  You remember URLs, right?  That's how you got to this page.

URLs are just addresses detailing, very specifically, **where you want to go**.  Intents, on the other hand, detail **what you want to do**.

Think of it like this, if a URL is like saying "I want to go to Yumz Frozen Yogurt on Boughton Street", an Intent is like saying "I want to eat frozen yogurt".

Think of how powerful that is.  In order to use a URL I have to know every business in town (apps) and decide specifically which one I want to go to (Yumz).  With an Intent, I don't have to know or care what businesses (apps) there are, since the system can tell what I want to do and find the appropriate one (or ask the user to choose).

On Android, this can translate into anything from "I want to edit a photo" to "I want to dial a number" to "I want to view a URL".

# Use Cases

While it's not strict or official, I like to think of two basic use cases for Intents, **actions** and **requests**.

In the case of actions you are specifing that you want to perform an action on the data you are specifying.  This action could be anything like `ACTION_VIEW`, `ACTION_DIAL`, `ACTION_DELETE`, and `ACTION_EDIT`, among others.

In the case of requests you are saying that would like to get a piece of information back.  This is usually an `ACTION_PICK` or `ACTION_GET_CONTENT` action.

# Performing Actions

Action Intents&trade; (as I like to call them) are often  fired off using [Activity.startActvity()](https://developer.android.com/reference/android/app/Activity.html#startActivity(android.content.Intent)).  This tells the system to find the best activity to handle your Intent, prompting the user to choose one if there are more than one match with no default, and launch it.

This is particularly valuable since you don't need to include a WebView in your app just to view your terms of service, nor do you have to know which photo sharing services your user likes to use.

Using [Intent Filters](https://developer.android.com/guide/components/intents-filters.html) your app can even be included in the list of available apps to handle certain Intents.  As an example, my app [Fragment](https://play.google.com/store/apps/details?id=com.pixite.fragment) does exactly that, so any app that allows you to edit photos outside of itself will include Fragment as an available option.

# Requesting Content

Request Intents&trade; are great ways to allow your app to work with data outside of itself without you needing to worry about the mundane details.  They are generally fired using [Activity.startActivityForResult()](https://developer.android.com/reference/android/app/Activity.html#startActivityForResult(android.content.Intent, int)) to send the request and [Activity.onActivityResult()](https://developer.android.com/reference/android/app/Activity.html#onActivityResult(int, int, android.content.Intent)) to receive the response.

As an example, if you want to allow your user to choose a Contact, you can simply fire an Intent with an action of `Intent.ACTION_PICK` and a data Uri of `Contacts.CONTENT_URI`.  This will launch the user's default contacts app and allow them to choose a contact.

```
Intent intent = new Intent(Intent.ACTION_PICK);
intent.setData(Contacts.CONTENT_URI);
startActivityForResult(intent, 1);
```

There are a couple of reasons why this is preferrable to writing your own contact picker.  First of all, you don't have to write any UI code to implement this.  Whichever contacts app the user prefers has already done that and, unless you're writing a contacts app yourself, they've probably done a better job.  (As an extreme example, this means you could write a whole app that doesn't have any UI of it's own, like Dan Lew's [QuickMap](https://play.google.com/store/apps/details?id=com.idunnolol.quickmap).)

Secondly, you don't know where the user stores their contacts.  Don't underestimate how complex this can be.  For instance, instead of using built in contacts from the phone, your user could be storing their contacts in a cloud service, an Exchange service, or a text file on the file system.  You don't need to account for all of the possibilities when you use an Intent.

This is particularly important, in my opinion, in the case of photos.  Users store photos everywhere, Dropbox, Google Drive, Google Photos, Facebook, the local photo gallery, on the file system (e.g. Downloads), and many other locations.  When writing an app that uses photos, you can't know everywhere that users can store then, so using a photo picking Intent such as the [Storage Access Framework](https://developer.android.com/guide/topics/providers/document-provider.html) allows you to let the user choose a photo from wherever they store them.

Lastly, when using an intent to perform certain actions, like dialing a number or viewing a web page, you [don't need to request special permissions](http://blog.danlew.net/2014/11/26/i-dont-need-your-permission/), which might scare some people away.

# Get Over the UI

Some people, particularly ones used to working on other systems, sometimes have a hard time with the fact that, using intents for actions or pickers gives you less control over the look and feel of the app on the other end.  My solution: Get over it.

Having a cohesively branded app is one thing, but restricting your user's choice, and spending your time on little things instead of your core product, is a poor choice in this author's opinion.

A perfect example of an offender here is Microsoft's Xim photo sharing app.  Instead of using Android's Storage Access Framework, which would allow me to choose any photos I want, their app allows me to choose from my Camera Roll (really?), or online service like OneDrive (don't use), Dropbox (don't use), Facebook (don't use), or Instagram (not the photos I want).  While I understand their desire to up-sell OneDrive, this app is useless to me since I can't access **my** photos.

For [Fragment](https://play.google.com/store/apps/details?id=com.pixite.fragment), we use the Storage Access Framework to allow the user to choose a photo from wherever they store them.  This allows users to choose their photos, wherever they may be, and immediately return to the Fragment app to continue editing their photos.

# Use Intents

In my opinion, as app developers, we should be focusing on how we can provide the most value to our users.  In some cases that means using what Android provides for us so that we can spend our limited resources on what really makes our app stand out.

Intents make this very easy, and should not be overlooked when it comes to building high quality Android apps.

*Thanks to [Dan Lew](http://danlew.net) for proofreading this post.*

---


<sup>Note</sup> None of the &trade;'d terms in this article are actually &trade;'d by me, they're just terms that I use that aren't official.

<sup>Note</sup> I also recognize that this doesn't deal with all uses of Intents, like starting Services or broadcasting messages.  I'm trying to keep things simple and those are topics for another discussion.