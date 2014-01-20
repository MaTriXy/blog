---
layout: post
title: "Creating an Android Project"
date: 2013-10-03 15:33
comments: true
categories: 
published: false
---

{% note %}
This is the third post in my Start to Finish series.  Last time I talked about source control with <a href="/blog/2013/09/25/getting-started-with-git/">Git</a>.
{% endnote %}

We've talked about [basic tools](/blog/2013/09/25/developing-an-android-app-start-to-finish/), and about [source control](/blog/2013/09/25/getting-started-with-git/), so now we're ready to get into actually creating an Android app.

In this part of the series, we're going to create a new project using [Android Studio](http://developer.android.com/sdk/installing/studio.html).  Android Studio is Google's Integrated Development Environment (IDE) that we will use to create our Android app.  While it's still in early preview release status, it will be replacing Eclipse as the main Android development IDE, so we'll go ahead and just start there.

Assuming you have already installed Android Studio, start it up and you will be greeted by a welcome screen, inviting you to create or import a project.

{% img center /images/posts/start-to-finish-3/project-creation-1.png "Android Studio welcome screen" %}

<!-- more -->

Once you have opened some projects in Android Studio you'll have quick access to them in the left hand pane here, but for now we're just going to click "New Project".

{% img center /images/posts/start-to-finish-3/project-creation-2.png "New Project screen" %}

Now you should see a default New Project screen.  Here we set all of the basic settings for our new project so that Android Studio can generate the appropriate file structure and build files.  Lets run through this screen one piece at a time.

1.  **Application Name**

    This is the Application Name as it will be shown in the Play Store, and on your app's launcher icon on your device.

1.  **Module Name**

    This is the name of the module in Android Studio.  It's not overly important at this point, as it only defines how you reference this project in Android Studio.  When we have multiple modules (like libraries) in a single project is when it matters.

1.  **Package Name**

    The Package Name is a unique identifier for your app, but users will generally never see this.  The convention here is to use a reverse domain name, which you can see I do.  Keep in mind, this is how Android determines if two apks are the "same app", so this must be unique and can never change for the life of your app.

1.  **Project Location**

    This one is pretty self explainatory.  Pick a folder here where you want your project to be stored.  I put a `code` folder in my home directory where all of my projects go.

1.  **Minimum required SDK**

    This is an important one, as it defines the minimum Android version that your app will run on.  Generally, I like to check the [Android Distribution Dashboards](http://developer.android.com/about/dashboards/index.html) to see what the current version distribution is when I'm starting my project.

    This is a common topic of discussion, with 8 being the old standard.  Now that ICS+ has almost 75% of the market, many people are moving to minimum SDK version of 14 (ICS), though we can see that SDK version 14 doesn't even make the dashboard, so we can safely move to API 15.

    This is important because you can only safely use Android features from your minimum version and above.  You can use newer features, but you have to check the OS version each time to make sure you aren't trying to call methods on a system that doesn't have them.

1.  **Target SDK**

    This tells Android which version of Android you are targeting, and doesn't have many immediately visible effects.  The general rule here is to have the Target SDK be the **latest version of Android you know about at development time**.

    Android uses this to determine what compatibility features are required.  For instance, prior to SDK 14 (ICS) all Android devices were required to have a hardware menu button.  Many apps relied on this for certain functionality, so on devices running ICS or higher, if your app has a target SDK below 14, your app will display a compatibility menu (three little dots in the navigation bar).

    I, personally, hate seeing an app that displays the compatibility menu as it screams "I'M A DEVELOPER WHO DOESN'T KNOW OR CARE ABOUT ANDROID!".

1.  **Compile with**

    This is the SDK version that will be used to compile your app.  Like the Target SDK, you generally choose the latest SDK version available so that you have all of the latest APIs available.

1.  **Language Level**

    This tell the code completion and verifier what Java language level you want to develop at.  The value here is dependent on your Compile with options, but as of SDK 19 you can use 7.0 which gives you diamond initializers and multi-catch statements, among other niceties.  Note that unless your minimum SDK is version 19 you can't use try-with-resources

1.  **Theme**

    This one should be pretty self explainatory, as it lets you choose the base theme for your app.  This is entirely dependent on your app design.  You can read more about app themes in the [Styles and Themes](http://developer.android.com/guide/topics/ui/themes.html) guide.

1.  **Create custom launcher icon** and **Create activity**

    These ones do just what they say.  I tend to leave them checked, and we will definitely use the auto created sample activity from this, so make sure that one is checked.

1.  **Mark this project as a library**

    If we were making an Android library, we would check this, but for this project we'll leave this unchecked.

