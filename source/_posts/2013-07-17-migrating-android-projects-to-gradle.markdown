---
layout: post
title: "Migrating Android Projects to Gradle"
date: 2013-07-17 08:36
comments: true
categories: 
 - Android
 - Gradle
 - build
---
{% img center /images/posts/gradle_logo.gif %}

I've been using ant to build my Android projects for as long as I can remember.  There are many reasons for this, like build consistency and workstation agnosticism, but you can read [this](http://ryanharter.com/blog/2013/06/17/introducing-gradle/) article if you want to check that out.

Ant is a good tool, but never offered the flexibility that I would have liked in a project.  That's where Gradle steps in.

After seeing all of the power of the new Gradle build system, I knew I had to convert [Hashnote](http://hashnoteapp.com) to Gradle.  Google has some great [documentation](http://developer.android.com/sdk/installing/migrate.html) for migrating if you already build with Eclipse, but that doesn't work for me.

<!-- more -->

# The Build File

Like Ant, Gradle builds use text based build files.  These build files can be quite simple, but also allow you to do so much.  This file is what allows Gradle to give such consistent builds regardless of workstation configuration.

### buildscript Block

The project build file starts out with a buildscript block.  This just tells Gradle what tools it will use for the script.  In our case, we will be using the Android tools.

Notice how we also apply the `android` plugin.  This line is what gives us the ability to customize and build Android projects.

	buildscript {
	    repositories {
	        mavenCentral()
	    }
	    dependencies {
	        classpath 'com.android.tools.build:gradle:0.5.+'
	    }
	}
	apply plugin: 'android'

### dependencies Block

Gradle handles dependencies for you, usually using Maven as a back end.  This is a huge step up from ant, which didn't do any dependency management.

Below is an example of a dependency block to include all of the jar files in the libs directory, and also fetch the NineOldAndroids library from Maven.

	dependencies {
	    repositories {
	        mavenCentral()
	    }

	    compile fileTree(dir: 'libs', include: '*.jar')
	    compile 'com.nineoldandroids:library:2.4.0'
	}

Importing jar files from the libs directory is a holdover from the Ant days, but is also very useful and will be needed on many projects.

### android Block

All Android specific customizations go in the android block.  This configures the Android plugin and can be quite simple.

	android {
	    compileSdkVersion 17
	}

# Keeping the Project Structure

In some cases developers might want to keep the `/src` and `/res` directory structure of Ant in tact.  This decision depends on the size and complexity of your project, and also other dependencies.

If you do want to keep the old project structure, you simply need to define your custom source sets in the gradle.build file.

	android {
	    sourceSets {
	        main {
	            manifest.srcFile 'AndroidManifest.xml'
	            java.srcDirs = ['src']
	            resources.srcDirs = ['src']
	            aidl.srcDirs = ['src']
	            renderscript.srcDirs = ['src']
	            res.srcDirs = ['res']
	            assets.srcDirs = ['assets']
	        }

	    }
	}

Using this sourceSets configuration allows projects to build with the legacy ant structure.  This is great if you want to try out Gradle without getting both feet wet.

# Using the New Project Structure

With Hashnote, I decided to go all in.  I decided that the legacy project structure was just a bandaid and modified my project to match the new system.

Unlike ant, Gradle has an extra level in it's projects.  This allows you to easily isolate library code from project code, and have many modules in your project.

The basic structure for Hashnote looks like this:

* /build.gradle
* /settings.gradle
* /Hashnote
* /Hashnote/build.gradle
* /Hashnote/src/main/AndroidManifest.xml
* /Hashnote/src/main/java
* /Hashnote/src/main/res
* /Hashnote/src/main/aidl
* /Hashnote/src/main/assets
* /Hashnote/src/instrumentTest/java

To migrate your project, the easiest way that I found was to just create and move the files.

	# Move the main components
	mkdir -p  Hashnote/src/main/aidl Hashnote/src/instrumentTest
	mv src Hashnote/src/main/java
	mv res Hashnote/src/main/res
	mv assets Hashnote/src/main/assets
	mv AndroidManifest.xml Hashnote/src/main/

	# Move the tests
	mv HashnoteTest/src Hashnote/src/main/instrumentTest/java
	rm -rf HashnoteTest

	# Create the build files
	touch build.gradle
	touch settings.gradle
	touch Hashnote/build.gradle

The next step is to fill in the build files.

#### settings.gradle

	include ':Hashnote'

#### build.gradle

The build.gradle file can easily be empty, but Android has a great wrapper that allows gradle to set itself up and run on any platform, so we use this file to generate that wrapper.

	buildscript {
	    repositories {
	        mavenCentral()
	    }
	    dependencies {
	        classpath 'com.android.tools.build:gradle:0.5.+'
	    }
	}

	apply plugin: 'android-reporting'

	/**
	 * Task to generate a gradle wrapper.
	 */
	task wrapper(type: Wrapper) {
		gradleVersion = '1.6'
	}

Once you run `gradle wrapper`, this will generate some more files in the root of your project.  From now on, instead of using the `gradle` command, we will use `./gradlew` instead.

#### Hashnote/build.gradle

This is where all of the magic happens.  When you run `./gradlew build` from the root of the project, the settings.gradle file will tell Gradle to use this file, along with any other libraries you might include there.

	buildscript {
	    repositories {
	        mavenCentral()
	    }
	    dependencies {
	        classpath 'com.android.tools.build:gradle:0.5.+'
	    }
	}
	apply plugin: 'android'

	dependencies {
	    repositories {
	        mavenCentral()
	    }

	    compile fileTree(dir: 'libs', include: '*.jar')
	    compile 'com.nineoldandroids:library:2.4.0'
	}

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

	android {
	    defaultConfig {
	        versionCode 20
	        versionName getVersionName()

	        minSdkVersion 15
	        targetSdkVersion 17
	    }

	    compileSdkVersion 'Google Inc.:Google APIs:17'
	    buildToolsVersion "17.0.0"

	    signingConfigs {
	        release {
	            storeFile file('my.keystore')
	            storePassword 'storepassword'
	            keyAlias 'keyalias'
	            keyPassword 'keypassword'
	        }
	    }

	    buildTypes {
	        release {
	            signingConfig signingConfigs.release
	        }
	    }
	}

Things are relatively straight forward here, with teh exception of the `getVersionName` function.  For my projects, I use git tags for each release, and this just gets the latest git tag to set the version string in the manifest.  This is based on a great article [here](http://osteslag.tumblr.com/post/7769890357/using-build-and-version-numbers-and-the-art-of).

Another thing to note is the `android.defaultConfig` section.  This is where you can set all of your requirements for the manifest that will automatically be set in the generated manifest.

The rest of the settings here are just things you would normally find in your project.properties file.

# Conclusion

Gradle has been great so far.  I've used it for quite a few client projects so far, and it's been great.  The fact that Android Studio builds using this, along with the command line and CI servers like Jenkins means you'll never have to worry about where your building and what the configuration is.

Check it out, and share your experiences in the comments below.