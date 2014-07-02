---
layout: post
title: "A Modern CI Server for Android"
date: 2014-07-02 17:37
comments: true
categories: 
published: false
---

As a freelance Android developer, I've gotten the opportunity to work with many different client environments when it comes to building and releasing Android (and other) apps.  One of the things that I've learned over the years is the importance of a good build server.

# Why CI?

Continuous Integration servers, or CI servers, are designed to checkout your code after each push and build your project, including any tests you might have.  This allows you to be notified immediately if and when you commit code that doesn't compile or fails tests. Especially when working in teams, this can offer increased reliability and peace of mind.

<!-- more -->

Another great benefit to a CI server is that you are forced to have standardized builds. This means that all developers will be able to build your project, and you can be guaranteed that it is being built exactly the same every time.  Your CI server can even inject things like build numbers directly into your project.

# Where Jenkins Falls Short

The CI server most of my clients and colleagues seem to work with most is [Jenkins](http://jenkins-ci.org).  I've worked with Jenkins quite a bit over the years and it certainly does the job, but it is also quite dated and falls short in a few regards, in my opinion.

First, Jenkins is entirely configured via a web interface.  While this can be convenient for quick updates, it means that the scripts and configuration that are building your project don't live with the code. This also means that your build scripts aren't version controlled.  If your build scripts are non-trivial then this can be a management nightmare.

Second, Jenkins doesn't really isolate your builds.  Sure, each project is checked out to a different workspace (directory), but they all use the standard system environment.  This is particularly painful for me since any time a new version of Android Studio and the Android build tools are released, I have to ensure all of my client's Jenkins servers are updated before I can update locally.  This usually involves a QA Specialist logging into each server (the main server and all build slaves) and updating the Android SDK as needed.

# The Search

In my search for a modern CI server, I had a hard time finding something that solved these problems, supported Android builds, and was open source (not strictly required, but nice).  

I checked out [Travis](http://travis-ci.com) as it uses yaml files in the project for configuration, but at the time it didn't have Android support and it's pricing for private repos is unreasonable ($129/month isn't reasonable for me).

I also checked out [CruiseControl](http://cruisecontrol.sourceforge.net/), but it has the same issues as Jenkins, and is hosted on SourceForge. Yeah, SourceForge.

Then I came across [Drone](https://drone.io), which caught my eye.  Drone is designed around [Docker](http://www.docker.com/) containers, meaning every build runs in it's self contained, *script configured* environment.  The hosted version of Drone doesn't support Android, but it's also available as an open source project, so I could extend it however I wanted.

# The Solution

I was eventually able to get a Drone CI server up and running on my own server at Digital Ocean (not related to my own consultancy, Analog Ocean), that builds my Android projects.  Here's how you can, too.

{% note %}
I've submitted a <a href="https://github.com/drone/images/pull/33">pull request</a> adding Android support to Drone.  Once it is merged in this process will be much simpler.
{% endnote %}

The first step was to setup a Drone server on Digital Ocean.  That was simply done by following [this guide](http://jipiboily.com/2014/from-zero-to-fully-working-ci-server-in-less-than-10-minutes-with-drone-docker).

Next, clone my fork of the images repo and build the android images.

``` sh
cd /tmp
git clone https://github.com/rharter/images.git
git checkout android_support
cd builder
sudo docker build --rm -t bradrydzewski/android:r23 builder/android/android_r23/
```

Once you do this, your server is all set up.  Then you simply have to add a `.drone.yml` build script to your project.  Here's what mine looks like.

``` yaml
image: bradrydzewski/android:r23
env:
script:
  - ./gradlew test assemble -PdisablePreDex
notify:
  email:
    recipients:
      - ryanjharter@gmail.com
```

This tells Drone to use the `bradrydzewski/android:r23` docker container that you just created, and then run `./gradlew test assemble -PdisablePreDex` to build your project.  If you have your server set up with an SMTP server, you will receive an email for failing builds at the email address provided.

## One Caveat

One thing that I woudl really like that Drone doesn't offer is incremented build numbers. I'd like to inject an always incrementing number into my projects as the `versionCode`, but at this point that's something I have to do manually.  I'm currently working on a solution to this and will share it shortly.

# Happy Building

That's all there is to getting a modern, script driven CI server up and running for your Android projects.  If you have any other solutions, or any questions about this one, share in the comments.