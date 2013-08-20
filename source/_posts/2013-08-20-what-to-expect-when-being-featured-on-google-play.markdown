---
layout: post
title: "What to Expect When Being Featured on Google Play"
date: 2013-08-20 08:48
comments: true
categories: 
---

{% img center /images/posts/what-to-expect-when-being-featured/play_picks.png %}

It's been a few weeks since my last post, in large part because of all of the work I've been doing for [Hashnote](http://hashnoteapp.com).  For those who don't know, in the beginning of August Hashnote was featured on Google Play in the Play Picks section.  Here's how it went.

<!-- more -->

# Before

In January of 2012, I decided to leave my 9 to 5 and start my own business as a freelance Android developer.  I had landed a large client and started working on some cool projects.  One of the benefits of this was that it gave me some more time to work on my own projects.  I had recently sold my [BGR](https://play.google.com/store/apps/details?id=com.bgr) app to Boy Genius Report, so I needed a new project.

# Enter Hashnote

In February I started development on Hashnote.  I wanted a fairly simple project that I could release as an MVP without a ton of time investment.  Hashnote 1.0 was released in March, with a simple, yet concise, feature set.  I pared it down to a simple way to take notes, using hashtags and @ mentions to organize, and nothing else.

I knew that people would request other features, but I wanted to make sure people were interested before I invested a lot of time into the project.

The initial response was excellent, with close to 5 start average ratings in the Play Store, and many requests from users.  While Hashnote didn't do everything, including sync, people loved how simple and easy it made jotting down quick notes.

During the first couple of months, I got a few thousand download and hovered around 1,000 active installs.  After the initial buzz wore off, that's about where I stayed, with around 10-30 new active installs per day.

# Initial Contact

In the end of June I woke up to an email from Nick Butcher, a well known Android Developer Advocate from London.  He informed me that they had come accross my app and liked it, saying that they were interested in featuring it on the Play Store.  He also sent a list of three blocking issues, including one crasher and two issues with marketing material, that I would need to fix before it could be featured, and also six or seven feature requests from the review committee.

I worked over the next few days, leading into a week or two, to fix the issues and implement several of the feature requests that aligned with my vision of Hashnote, and emailed Nick to inform him that Hashnote was ready to be featured.  As I waited, I worked hard to create a web interface for managing notes, and making sync solid, as that was my number one requested feature.  I didn't know when or for how long Hashnote would be featured, so I wanted to make sure that I could capitalize on that time to gain as many loyal fans as possible.

# Waiting

Several weeks went by and I hadn't seen any change in Hashnote installs, and still hadn't heard anything from the Google teams about when Hashnote would be featured.  I was a little afraid to make any updates to Hashnote in that time, thinking that maybe I would have to start the review process over if I did.

After not hearing anything for a while, I decided that it wasn't worth making my users wait for updates.  After evaluating the business, I decided that my model of a free app with paid sync feature wasn't sustainable, especially since I wanted to get as many people using the app as possible, and sync with a web interface is a huge selling point for people.  Having done ad based apps before, I decided that I would put ads in Hashnote, something I had been fighting since the beginning, but give users the option to remove them with a simple purchase.  

This was perfect for people who didn't want to purchase the app, and also for those who did.  I felt that it also provided a nice "trial period" for users to get used to the app, and purchase it if they liked it.

I knew that users who had purchased sync would be upset if I made it free for everyone and didn't give them anything, so I automatically removed ads for anyone who already purchased sync.  I expected that I would see some upset users from this, but not one user complained about the transition.

# Catch.com Announces Their Closure

In early August, Catch.com, a popular note taking app on Android with five to ten million download, announced that they would be closing their doors (really just pivoting as a company).  On the next day, the same day that I released the ad supported with purchase option app, I saw a jump in my downloads.  While I had been getting 50-60 downloads per day, I now got 1700 is one day.

# Play Picks

The numbers astonished me, and I assumed it had all come from the Catch announcement.  The next day, after seeing 2500 new installs, I checked the Play Store and, sure enough, Hashnote was right there, alongside four other apps, in the Play Picks section.

{% img center /images/posts/what-to-expect-when-being-featured/total_downloads.png %}

As you can see from the total downloads above, after about a week of being featured, I was able to get roughly 15,000 new downloads.  This may not be a lot for an app with 1,000,000 downloads but for my app, and only six months after initial release, this was a huge boost that helped me out.

Along with downloads, the emails and comments started rolling in.  I made an effort to respond to every email I received, which were mostly filled with praise for the app, and requests for new features.  I wanted to make sure that I was responsive and used this time to show all of these users that I cared, and would work hard to make a great product that they could depend on.

# Sync Issues

It wasn't all unicorns and rainbows, however.  Along with all of this usage, the [Mobile Backend Starter](https://developers.google.com/cloud/samples/mbs/) based App Engine backend that I used for sync wasn't quite cutting it.  App Engine did a great job of making sure that the app scaled flawlessly to support the new load, but I found that I had to keep raising my daily budget just to keep up.  I was making some money from in app purchases, and some more from ad revenue, but the server costs were taking a large chunk of that revenue.

The costs of the server were initially feasible because of the sales and ad revenue, but it wasn't going to scale.  My wife also wasn't too happy to hear that my server costs were eating into 20-30% of my app revenue.  Along with some reliability issues with sync, I decided that I needed to spend the time to create a new backend that would be more efficent for users, and for me.

In my rush to appease the users (hmm, I should watch Tron again), I spent an entire weekend while my wife was out of town writing a new sync backend, from the ground up, that would use [Google Cloud Messaging](http://developer.android.com/google/gcm/index.html) so that apps would only sync when necessary, instead of constantly polling the server.

Though I wasn't using the Mobile Backend Starter anymore, it still served as a great foundation, helping me easily figure out how to utilize memcache to keep performance top notch, and use the new Datastore Namespaces to ensure all user data was kept separate and secure.

I released the new version of the app, with the new backend, on Monday, and immediately started getting complaints that sync wasn't working.  I was astonished, I had worked hard to make sure that sync worked without fail in my tests, but user's still couldn't sync.

After several days of several updates trying to fix the issue, I finally narrowed the issue down to the release certificate and API registration that allowed my app to talk to the backend.  Since App Engine's versioning didn't quite cut it for a clean transition, I had to move the backend code to a new project, and an app can only access on project at a time, so I was forced to cut off access to the old backend for everyone, and hope they updated their app if they used sync.

Since sync is off by default, only the users that dive into the settings use it.  This seemed to make this transition fairly painless, once I transferred the signing certificate.  

After making this change, my server usage went from averaging 12 requests per second, to less than one.

{% img center /images/posts/what-to-expect-when-being-featured/usage.png %}

You can see here, with the old server stats on the top, and the new server on the bottom, how I was able to make my server costs go from $10 per day, back into the free tier of App Engine.  Now my server costs are up to around 10-20 cents per day.

# After the Feature

{% img center /images/posts/what-to-expect-when-being-featured/active_installs.png %}

As you can see by my active install graph, Hashnote is no longer being featured, after about a week, and my growth has slowed down quite a bit.  I now see a couple hundred new installs per day, but I feel that my user base is finally high enough that I have a real app that shows potential.

I have an active and growing user base that keeps me on my toes, and keeps me motivated to continue creating a great app.  I've improved the [web interface](http://hashnoteapp.com) in response to my users, to make editing your notes across devices a seamless experience.

# How to get Featured

People often ask, as I have in the past, how to get featured on the Play Store.  I never thought the general answer of "make a good app" was sufficient, and thought there had to be more to it.  I was wrong.

Though I do have some connections from my time working with Android and Google, I have none that helped out in this instance.  I had never communicated with Nick Butcher before receiving his email, and never reached out to anyone I know to try to get featured.  I just wrote a good app, that had really good ratings, and they reached out to me.

# Unexpected Outcomes

During and after the Play Store feature, I monitored Hashnote on twitter, and was surprized to see that many of the tweets were for Spanish and Russian blogs offering reviews of the app, and bringing in a lot of users.  Hashnote isn't localized yet, but I do plan on doing it soon, as soon as I have some revenue to support it, to help out the users who don't speak English.

If you've checked out Hashnote and have something you'd like to share, or have questions about the feature and what it offered for me, share in the comments below.

<a target="_blank" href="https://play.google.com/store/apps/details?id=com.ryanharter.hashnote">
<img  class="center" alt="Get it on Google Play" src="https://developer.android.com/images/brand/en_generic_rgb_wo_45.png">
</a>