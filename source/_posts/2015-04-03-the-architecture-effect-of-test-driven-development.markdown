---
layout: post
title: "The Architecture effect of Test Driven Development"
date: 2015-04-03 13:00:20 -0500
comments: true
categories: 
published: false
---

I've finally done it.  In the latest client project I'm working on I've decided to take a test first approach.  I've been wanting to experience Test Driven Development on Android for years, but have never felt comfortable enough to really commit.  After reading through Kent Beck's book and checking out Corey Latislaw's latest [book](https://gumroad.com/l/androidactivitybook), I decided I was ready to make the leap.

I'll write some more later about my experience, reactions, and what I've learned, but today I wanted to share a slightly unexpected benefit.

## Architecture

As I changed my software cycle to writing tests first to define the requirements, it's changed how I architect my apps.  I spend just a little bit more time thinking through my architectural decisions before putting them into practice, and writing tests first allows me to build an API, use a mocked out implementation of it, and confirm that that design actually meets my needs.  Only then do I do the work to implement the API.

One of the things this mentality has helped me identify is when I've failed to properly encapsulate portions of my code.  Often times, as developers, we have a problem to solve and design a solution that fits into what we're working on at the time, but without the requirement to really plan a good architecture (read: single developer projects), it can be tempting to 