---
layout: post
title: "Going ICS Only"
date: 2013-07-07 21:24
comments: true
categories: 
  - Android
  - Programming
  - ICS
---
Back in April I had the pleasure of seeing a talk by Jay Ohms of [TwentyFive Squares](http://twentyfivesquares.com) at [GDG Schaumburg](http://gdgschaumburg.com/).  It was a great discussion about their app, [Press](https://play.google.com/store/apps/details?id=com.twentyfivesquares.press), an excellent RSS reader for Android.

{% img center /images/posts/ice_cream_sandwich_logo.jpg %}

The discussion wasn't a technical one, but one of the things that interested me was their decision to go Ice Cream Sandwich and up for Press.  This was the first app that I had heard of, and the only major, popular app that I know of, that has made this decision.

My initial reaction was that they made a huge mistake.  How could they imagine making a business by cutting themselves off from so many potential customers?  What were they thinking?

<!-- more -->

After thinking about this for a little while, I went and looked at the statistics of [Hashnote](http://hashnoteapp.com).  I new all along that ICS+ devices made up a huge part of my user base, but I never really thought about it.  I've been developing Android apps for years and backwards compatibility was just something I did without thinking.

It was then that I noticed that of Hashnote's users, only 1.4% were actually using anything less than ICS.  After taking into account all of the work I had done to integrate ActionBar Sherlock, fix selected state drawables, and test everything on Gingerbread, I realized that it just didn't make sense.

I decided to rip out the compatibility layer and go ICS+ for Hashnote, and I've been amazed at how much better that has made things.  My development is much faster, and I no longer have to worry about old APIs.

Eventually I'll make the jump to Jelly Bean only, but, for now, Ice Cream Sandwich has a great place in my development.