---
layout: post
title: "Hosting a Private Maven Repo on Amazon S3"
date: 2015-06-18 16:09:34 -0500
comments: true
categories: 
published: true
---
Remember the olden days of Android development?  There were times when including a library in a project meant [relative links to source](http://developer.android.com/tools/projects/projects-eclipse.html#ReferencingLibraryProject), or using Maven. Fortunately for us, those days are long gone now with the introduction of Gradle.

Gradle has made developing and consuming libraries for Android amazingly simple, and has spurred a new boom in library development for Android. We've always had a large, open, inclusive community to boast of, but over the past year or two it has only gotten better as the community has matured.

<!-- more -->

## Why Use Compiled Dependencies

You may be wondering why you should distribute private, internal libraries as compiled dependencies (.aars or .jars) as opposed to simply sharing the code via something like Git. My answers are reusability and versioning.

When you have multiple projects that use shared components, it's important to ensure that they are using the same underlying code, as opposed to having the same code pasted into each project. This ensures that bug fixes and other changes are distributed throughout the projects and protects your code from diverging too much. This can be accomplished using git submodules, but that introduces other challenges, like proper versioning.

Versioning is important, even for private internal libraries, because it ensures consistent build quality. By ensuring that your consumers get the same dependency until they are ready to update, you don't have to worry about changing something in a library for one project and cuasing issues in your other projects. When you are ready to update your other projects, you can have a proper test cycle to ensure the integration is working as expected.

## The Maven Repository Server

If you want to share an open source library, there are many free, hosted solutions available. But if you have internal, private assets you want to deliver, it's a whole other story. 

Setting up and managing a Maven Repository Server, from which Gradle can download it's dependencies, isn't particularly challenging, and there are even a [few](http://www.sonatype.org/nexus/go/) [free](http://www.jfrog.com/open-source/) [options](http://archiva.apache.org/index.cgi) that make hosting a private Maven repo quite easy, but you still have to manage (and pay for) your own server. 

If you want a hosted solution, BinTray has a private offering for $45 per month, but even that can be challenging for individuals or small teams.

In some situations, like in companies where the developers mostly work on site that already have internal servers that they manage, using one of the repositories mentioned above is a perfect fit. The solution I outline below doesn't proxy other repositories, like Maven Central, for speed and reliability, it simply provides an easy way to host an authenticated repository.

Other dependency management solutions that weren't designed for the enterprise, like [Bundler](http://bundler.io/) and [Cocoapods](https://cocoapods.org/), make it easy to host your private dependencies using existing services, like authenticated git repositories. These tools were built by and for the community, so leveraging existing hosting mechanisms was a priority.

## Hosting Dependencies on Amazon S3

With the release of Gradle 2.4 comes support for Amazon S3 hosted maven repositories. This is a huge win for small development teams because S3 provides authenticated access that works with Gradle, and is quite affordable. So we finally have an easy solution to host private Maven repos without the need to stand up and manage a server.

In order to host your assets on S3, you'll first have to set up an authenticated bucket to serve as your repository. That's outside the scope of this article, but Amazon has some [excellent documentation](https://aws.amazon.com/documentation/s3/) detailing how to do that.

Once you create the bucket, you'll need to add a bucket policy to ensure your authentication user has access to all files created within the bucket.

```json
{
  "Version": "2012-10-17",
  "Id": "Policy1428433847297",
  "Statement": [
    {
      "Sid": "Stmt1428433844452",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::1234567890:user/maven-user"
      },
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::pixite-maven"
    },
    {
      "Sid": "Stmt1428433844452",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::1234567890:user/maven-user"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::pixite-maven/*"
    }
  ]
}
```

Notice that my group has access to list the pixite-maven bucket, and also permission to get and put objects in any subdirectories of the bucket. You can restrict this however you want according to Amazon's documentation.

If you're hosting both snapshots and releases in a single bucket (like I do), you'll probably want to add those directories into the root of your bucket. Another option is to have two buckets that can be managed independently, one for snapshots and one for releases.

The next step is to ensure that you're using gradle 2.4 for your project. This can be done by editing your `gradle-wrapper.properties` file, or by simply adding the following snippet to your root build.gradle file, and running `./gradlew wrapper`.

```groovy
task wrapper(type: Wrapper) {
    gradleVersion = '2.4'
}
```

Now, wherever you normally set the repositories you need access to (I use an `allprojects {}` block in my root build script), simply add your Amazon S3 bucket as a maven repository.

```groovy
repositories {
    maven {
        url "s3://pixite-maven/releases"
        credentials(AwsCredentials) {
            accessKey AWS_ACCESS_KEY
            secretKey AWS_SECRET_KEY
        }
    }
    maven {
        url "s3://pixite-maven/snapshots"
        credentials(AwsCredentials) {
            accessKey AWS_ACCESS_KEY
            secretKey AWS_SECRET_KEY
        }
    }

    mavenLocal()
    jcenter()
}
```

Notice how the url of the repository is `s3://[bucket name]/[path]`. Also, since this is a private repository, I'm including my AwsCredentials in the maven block. While you could put your actual `AWS_ACCESS_KEY` and `AWS_SECRET_KEY` directly in your build file, DON'T! Your build files shouldn't ever include credentials, since then you can't really manage access. Those values are exactly what's in my build file, allowing it to read from the user specific gradle.properties file in my home directory. Here's where I set the actual values, in `~/.gradle/gradle.properties`:

```
AWS_ACCESS_KEY=my_aws_access_key
AWS_SECRET_KEY=my_super_secret_key
```

That's all that's needed to host your dependencies on Amazon S3, allowing you an affordable, access controlled option for internal maven hosting without the management overhead.

{% note Not for Open Source libraries %}
<p>If you are distributing an open source library that you want others to use in their projects, this is not the solution for you. BinTray (jcenter) and Maven Central are the place to distribute open source code. This allows users of your libraries easy access without the need to add custom repositories throughout their projects. This is only the solution when you need an authenticated repository, or if you need to distribute your library without the source code (ala Fabric).</p>

<p>To read about how to distribute your libraries to BinTray and Maven Central, read <a href="http://inthecheesefactory.com/blog/how-to-upload-library-to-jcenter-maven-central-as-dependency/en">this great post</a> by fellow GDE Sittiphol Phanvilai.</p>
{% endnote %}