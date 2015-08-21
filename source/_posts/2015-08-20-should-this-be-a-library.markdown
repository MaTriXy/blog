---
layout: post
title: "Should this be a library?"
date: 2015-08-20 21:04:28 -0500
comments: true
categories: 
  - Development
  - Libraries
published: true
---
I come from the consulting world, where it's common to try to make everything a library.  This makes perfect sense, boost profit margins by writing something once and selling it to everyone.

But often times this doesn't work out as expected for several reasons, the first of which is failing to ask the question "Should this be a library?"

Here are a few tips to help you decide if you should makes something a library or not.

<!-- more -->

## Do you have another place to use the functionality?

First of all, do you have another place to use the functionality.  Whether we're talking about custom widgets in your UI or utilities to help you accomplish certain tasks, it's important to make sure you have another place to use the functionality before you spend the extra time extracting the code into a library.

If you don't have another place to use the functionality, don't worry, just write it for the purpose at hand and you can always extract it later if something else comes up.  This also has the added benefit of letting you use it in practice to learn the best way to consume your code.

## Is there something else out there?

Second, is there some other open source library that accomplishes what you need?  Do your research to make sure you aren't just reinventing a wheel someone else has created.  If you come across a quality library that solves your problem, then you've just saved yourself all of the time it would have taken you to write it in the first place.

If you find some open source code that comes close to solving your problem but isn't quite there, get in touch with the maintainers to see how you can contribute.  Perhaps your missing feature is something that they've been looking for but haven't had the time to implement.  In that case, the open source community would welcome your contribution.

## Is the feature truly custom?

Sometimes the feature you're working on seems like it could be used many other places, but each implementation is quite different from the last.  This type of custom implementation is how us consultancies make it, and shouldn't be overlooked.

If you were to use a library and would have to customize most parts of the implementation, or alter the library code to make it work in differnet scenarios, then it probably doesn't make much sense to spend the time making a library out of it.

That's just a few tips to help you decide if you should really make a library.  Next time your sales team tells you to start making more libraries, be sure to ask these questions.