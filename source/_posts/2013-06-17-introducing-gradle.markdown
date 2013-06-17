---
layout: post
title: "Introducing Gradle"
date: 2013-06-17 14:00
comments: true
categories: 
  - Android
  - Programming
---
# Who Needs IDEs?

At Google I/O this year, Google introduced it's new IDE, Android Studio.  Android Studio is based on IntelliJ IDEA, a great IDE that many of my Android friends use.

{% img /images/posts/studio_splash.png %}

I wasn't particularly excited by this announcement because, for the last several years, I've given up IDEs.  My development environment of choice has been [Sublime Text 2](http://www.sublimetext.com/) and ant.

Sure, IDEs can be extremely useful, especially in Java, where boiler plate code is the name of the game.  But I found that they (Eclipse especially) were getting in the way more than they were helping.  I was able to get reasonable reflection based code completion using the great [SublimeJava](https://github.com/quarnster/SublimeJava) plugin, and I found ant builds from the command line to be amazingly more reliable than anything I could do with Eclipse.

<!-- more -->

# Gradle to the Rescue

There was one exciting part about Android Studio that really got me interested, however.  Gradle.

Now I've never been a Gradle user before, so the mere fact that Google was switching to this build system didn't really matter to me.  What I loved though, was the fact that the **IDE** was switching to this build system.

How many times have you tried to import someone elses code into Eclipse only to find that your settings weren't quite the same?  It's happened to me a lot, and that's why I chose ant.

With Gradle, Google has completely changed the game by provided a build system that both IDEs and command line builds can use that will utilize the same settings.  No more project files pointing to relative directories.  No more GUI settings screwing up the rest of the team.

# Switch

I've always been a bit proponent of Ant based builds, simply because the build.xml file gets commited and individual workstation configuration plays no part in the build.  Projects are amazingly portable when you think of it this way.

For almost the last month I have been using Android Studio, with the new Gradle build system, for my projects and have been loving it.  There were a few growing pains, but I got past them and it's been a pleasure ever since.

I'm now completely using Android Studio, and my builds are entirely automated using command line builds, including testing.

In a later post, I will detail how I migrated my Ant based project to Gradle and other interesting things I've learned to do with the new system.