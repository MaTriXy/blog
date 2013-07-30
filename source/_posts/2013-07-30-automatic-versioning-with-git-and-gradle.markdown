---
layout: post
title: "Automatic Versioning with Git and Gradle"
date: 2013-07-30 14:14
comments: true
categories: 
---
One of the challenges of programming projects is versioning.  I've always tried to find a simple way to bump version and build number in a meaningful way that uniquely identifies a build.

Back in the Subversion days this was easy, since Subversion is a centralized version control system that assigns a unique, incrementing revision number to each commit.  Free build numbers!  Then all you have to do is assign a marketing version number (something like 1.0) for each release.

## Git Ruined Everything! (Not Really)

After the world seemed to move to Git, this was no longer an option.  Git, as a distributed version control system, uses hashes to uniquely identify each commit.

<!-- more -->

A year or two ago I found a great system for [injecting build and version numbers with Git](http://webcache.googleusercontent.com/search?q=cache:HgjTAgG6DDwJ:stuff.bondo.net/post/7769890357/using-build-and-version-numbers-and-the-art-of+&cd=1&hl=en&ct=clnk&gl=us).  While this is iOS centric, the principal is sound.

## Gradle to the Rescue

Now that Android has moved to Gradle, I immediately saw an opportunity to automate my build numbers.  One of the things that I like about the Joachim's procedure is that it forces you to tag your releases.

I don't want to impose a git branching system on anyone, though I quite like [Git Flow](http://nvie.com/posts/a-successful-git-branching-model/), but release tagging is very important.  The idea is that, for each release, you tag the Git repo to make sure you know exactly which commit the release is based.

This simple gradle build script addition allows you to dynamically grab the marketing version number from your git tags.

	/*
	 * Gets the version name from the latest Git tag
	 */
	def getVersionName = { ->
	    def stdout = new ByteArrayOutputStream()
	    exec {
	        commandLine 'git', 'describe', '--tags'
	        standardOutput = stdout
	    }
	    return stdout.toString().trim()
	}

Set your Android version number to `getVersionName()`, tag each release with `git tag -a 1.0` and there you go.  Now each build will have a version like `1.0` taken from your git tags.

## The Happy Side-Effect

The happy side-effect of this is that each intermediary build will have a useful version like `1.0-9-abcd1234`, which includes the last version number, the number of commits ahead of the last version number, and the SHA1 hash of the commit that this build was made from.