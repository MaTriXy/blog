---
layout: post
title: "Developing an Android App - Start to Finish"
date: 2013-09-25 10:01
comments: true
categories: 
published: false
---

If you checkout the [Android Development](https://plus.google.com/communities/105153134372062985968) community on Google+, you'll find a lot of people asking how to get started building an app for Android.  Though quite a general question that can't really be answered in a social post, I understand how frustrating it can be to figure out where to get started.

There are plenty of tutorials on the web about how to accomplish specific tasks, but these generally don't cover the higher level parts of app development like version control and layout analysis.

In this series I'll be building an entire app.  At the time of this writing I haven't written a line of code for this app, so you'll get to work with me as I create an app, from scratch, that I will eventually submit to the Play Store.

# A Bit About Me

I'm a freelance Android developer based out of the suburbs of Chicago, Illinois, USA.  

Back in 2006 I published my first Mac app, [Simple Convert](https://www.macupdate.com/app/mac/24065/simple-convert), while teaching English in France.  It was a very simple app, but got me started in app development.

Since then, I've been a Mac desktop developer, a WebOS developer, a Web developer, an iOS developer, and an Android developer.  I've worked on a lot of great projects, and seen many projects through from start to finish.

In January of 2013, I quit my mobile development job and became a freelance Android developer.  Since then, I've built great apps for clients like Marvel Comics, American Idol, and Dell.  I've also built my own app [Hashnote](https://play.google.com/store/apps/details?id=com.ryanharter.hashnote) which was featured on the Play Store in August and has garnered quite a following.

# What We'll Develop

In this series, we're going to develop a disc golf score keeping app.  If you are unfamiliar with Disc Golf, also called Frisbee Golf or Frolf, it's much like regular golf, only with flying discs (Frisbee is a brand name by Wham-o).  Check out the [Professional Disc Golf Association](http://www.pdga.com) for more info.

{% img center /images/posts/start-to-finish-1/app_screens.png %}

With this app, users will be able to select a course from a list (or create a new one) and keep track of their score on each hole on the course.  The app will show them their overall score at all times, and also has a "shade" that can be pulled down to get the score card including each hole on the course.

This app is good for learning development because it involves several of the basic building blocks of Android development including lists, custom views, database access, sharing between apps, and more.  Eventually, we'll add network services for things like course discovery and social integration, but first things first.

Keep in mind, I don't consider myself a designer.  I designed these mockups in Photoshop, but I don't consider them to be overly beautiful design, so they can probably be cleaned up quite a bit.

# What You Can Expect

Many of the skills you learn through this series will be directly transferable to your own apps.  Almost every app has lists of data, detail views to show more data, local database access, and custom views.  I'll go through what I believe to be the best practices for all of those tasks.

This series is about more than just individual Android tasks, though.  I'll go through the actual process of building apps, complete with determining the best approach to solving a problem, using library projects, and using source control.

As we go along, all of the source code will be available on Github so that you can see exactly what I'm doing in the code.

# What You Need To Do

You need to know Java.  This isn't an introduction to programming series.  I can't possibly teach basic programming, though you will probably be able to pick up quite a bit as we go along.

If you want to follow along as we build this app, go download [Android Studio](http://developer.android.com/sdk/installing/studio.html) and perhaps play around a little to get your feet wet.

While not a necessity, I've really grown to like the [Genymotion](http://www.genymotion.com/) Android emulator.  I used to do most of my development on my full time phone because it was fast and gave me the exact experience that my users would get, but it's really nice to have an emulator that can be set up in different configurations and not interfere with all of my existing content and user accounts.  Genymotion runs on VirtualBox, and is as fast as, if not faster than, my Nexus 4, making development a breeze.

You'll also need to have [Git](http://git-scm.com/) installed so that we can start version controlling our code immediately.