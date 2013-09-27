---
layout: post
title: "Developing an Android App - Start to Finish"
date: 2013-09-25 10:01
comments: true
categories: 
published: false
---
<section>

If you checkout the [Android Development](https://plus.google.com/communities/105153134372062985968) community on Google+, you'll find a lot of people asking how to get started building an app for Android.  Though quite a general question that can't really be answered in a social post, I understand how frustrating it can be to figure out where to get started.

There are plenty of tutorials on the web about how to accomplish specific tasks, but these generally don't cover the higher level parts of app development like version control and layout analysis.

In this series I'll be building an entire app.  At the time of this writing I haven't written a line of code for this app, so you'll get to work with me as I create an app, from scratch, that I will eventually submit to the Play Store.

<!-- more -->

### A Bit About Me

I'm a freelance Android developer based out of the suburbs of Chicago, Illinois, USA.  

Back in 2006 I published my first Mac app, [Simple Convert](https://www.macupdate.com/app/mac/24065/simple-convert), while teaching English in France.  It was a very simple app, but got me started in app development.

Since then, I've been a Mac desktop developer, a WebOS developer, a Web developer, an iOS developer, and an Android developer.  I've worked on a lot of great projects, and seen many projects through from start to finish.

In January of 2013, I quit my mobile development job and became a freelance Android developer.  Since then, I've built great apps for clients like Marvel Comics, American Idol, and Dell.  I've also built my own app [Hashnote](https://play.google.com/store/apps/details?id=com.ryanharter.hashnote) which was featured on the Play Store in August and has garnered quite a following.

### What We'll Develop

In this series, we're going to develop a disc golf score keeping app.  If you are unfamiliar with Disc Golf, also called Frisbee Golf or Frolf, it's much like regular golf, only with flying discs (Frisbee is a brand name by Wham-o).  Check out the [Professional Disc Golf Association](http://www.pdga.com) for more info.

</section>
{% img center /images/posts/start-to-finish-1/app_screens.png %}
<section>

With this app, users will be able to select a course from a list (or create a new one) and keep track of their score on each hole on the course.  The app will show them their overall score at all times, and also has a "shade" that can be pulled down to get the score card including each hole on the course.

This app is good for learning development because it involves several of the basic building blocks of Android development including lists, custom views, database access, sharing between apps, and more.  Eventually, we'll add network services for things like course discovery and social integration, but first things first.

Keep in mind, I don't consider myself a designer.  I designed these mockups in Photoshop, but I don't consider them to be overly beautiful design, so they can probably be cleaned up quite a bit.

### What You Can Expect

Many of the skills you learn through this series will be directly transferable to your own apps.  Almost every app has lists of data, detail views to show more data, local database access, and custom views.  I'll go through what I believe to be the best practices for all of those tasks.

This series is about more than just individual Android tasks, though.  I'll go through the actual process of building apps, complete with determining the best approach to solving a problem, using library projects, and using source control.

As we go along, all of the source code will be available on Github so that you can see exactly what I'm doing in the code.

### What You Need To Do

You need to know Java.  This isn't an introduction to programming series.  I can't possibly teach basic programming, though you will probably be able to pick up quite a bit as we go along.

If you want to follow along as we build this app, go download [Android Studio](http://developer.android.com/sdk/installing/studio.html) and perhaps play around a little to get your feet wet.

While not a necessity, I've really grown to like the [Genymotion](http://www.genymotion.com/) Android emulator.  I used to do most of my development on my full time phone because it was fast and gave me the exact experience that my users would get, but it's really nice to have an emulator that can be set up in different configurations and not interfere with all of my existing content and user accounts.  Genymotion runs on VirtualBox, and is as fast as, if not faster than, my Nexus 4, making development a breeze.

You'll also need to have [Git](http://git-scm.com/) installed so that we can start version controlling our code immediately.

## 1. Tools

Let's call this first section a mini-lesson.  There aren't really actions, per-se, but I want to share with you the tools that I use in my development cycle.

### Text Editor - Sublime Text 2

Unlike many people my age, I still like using a text editor to make my apps.  I first switched to using emacs several years ago when my 2008 Macbook could barely run Eclipse.  

I felt that this might even improve my coding ability since I wouldn't be able to rely on code completion and I was right.  I didn't have anything to automatically import classes for me, so I've become intimately familiar with the API structure.  I also built a great habit of keeping the documentation open in a browser in one window while I code in another.  So many questions I see on Stack Overflow could easily be solved if people were just more familiar with the documentation.

After using just emacs for 6 months or so, I switched to [TextMate](http://macromates.com/), which hasn't be updated in years, and have since switched to [Sublime Text 2](http://www.sublimetext.com/).

Sublime Text is a really great editor.  It has a great plugin architecture, so you definitely need to install [Package Control](https://sublime.wbond.net/) a plugin that makes installing plugins super easy.

It's been a while since I've set mine up, but I really like the [SublimeJava](https://sublime.wbond.net/packages/SublimeJava) plugin, which gives reflection based code completion, among other niceties. 

Sublime Text can take a little bit of time to get set up exacly as you like, but I'd definitely recomment checking it out.

### Build System

For years I used `ant` to build my code.  This was in large part because the Android build system is based on ant, but also because I was using a text editor instead of an IDE that could build the code for me.

Since the announcement of Gradle at Google I/O, I've been using that to build my projects.  Gradle is excellent because it combines scriptable build logic with dependency management (based on Maven).

These build systems are superior, in my opinion, to building in IDEs like Eclipse or IntelliJ because they give you easily repeatable, scriptable builds that are consistent every time.  With no buttons to click or human intervention, you don't have to worry that you forgot to check a checkbox and might have messed up your build.

### Emulator

For years I never used an emulator.  The Android emulator that ships with the SDK is simply too slow and cumbersome to use on a day to day basis.  I was always a test-on-device kind of guy.

That's changed in the last few months when I learned about [Genymotion](http://www.genymotion.com/).  Genymotion is a fast - and I mean fast - Android emulator that runs on VirtualBox.  They've done a great job of making it fast and easy to create and run the emulator without all of that lag that comes with the SDKs emulator.

### IDE

As I said before, I never used an IDE...until recently.  At Google I/O 2013 Google announced [Android Studio](http://developer.android.com/sdk/installing/studio.html), a home built Android IDE based off of IntelliJ.  It's still in early preview mode, but with the IntelliJ base it's already quite usable.

I now find myself switching between my trusty text editor and Android Studio about 50% of the time.  Android Studio makes things very easy, allowing you to easily refactor code and create strings appropriately, but can also lead to sloppy code.

After years of text editor development, I got used to having to manage my imports and add my strings to my strings.xml file manually, meaning that everything was very well organized.  I don't think it added a lot of time to my build process since I got so comfortable in my process that I was quite fast.  IDEs definitely lose that level of clean organization by making things easy, but it's all a trade-off.

### SCM

Last but not least, I use [Git](http://git-scm.com/) for my SCM of choice.  Developed by Linus Torvalds, the man behind the Linux kernel, Git is a free and open source distributed version control system that makes version control fast and easy.

Unlike central version control systems like Subversion, Git is distributed, meaning you don't need a central server that acts as a master that everyone connects to.  More importantly, Git makes branching and merging easy and painless, something that Subversion could never do.

Git allows me to work on my project and 'branch' off on side tasks, like fixing a little bug or trying out an idea for a new feature, without interfering with the main development of the project.  When that feature or bug is complete, I can 'merge' that branch back into the main development branch of my repository so that everything works well together.  This is extremely helpful when working on a team, where multiple people need to work on multiple tasks at once.

I don't use a graphical interface for Git as the command line tools are extremely easy.  In the next article we'll get into the details of Git from the command line so that you have a basic idea of how to use it.

## The End

That's it for this week.  Check back soon to dive into managing projects with Git and getting everything set up to be a real Android developer.

</section>
