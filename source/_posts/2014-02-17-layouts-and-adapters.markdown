---
layout: post
title: "Customizing the ListView"
date: 2014-02-17 09:18
comments: true
categories: 
published: false
---

In the [last post](/blog/2014/02/07/creating-an-android-project/) we created a basic Android project using Android Studio templates. While it's great that we have a fully functioning master/detail style app, it does look a bit bare. In this post, we'll change this by styling our list view, incorporating (sort of) real data to feed our list.  We'll make a custom adapter to drive our list with custom layouts, and introduce testing into the mix to ensure that our app continues to perform as expected.

{% img center /images/posts/start-to-finish-4/styled-list-preview.png %}

At the end of this post, this is how your pet list will look.

As always, now is the time to make a new feature branch: 

``` sh
$ git checkout -b list_style
Switched to a new branch 'list_style'
```

## Add Test Library

Use Double Espresso from Jake Wharton.

``` gradle
dependencies {
  compile 'com.android.support:support-v4:18.0.0'

    instrumentTestCompile 'com.jakewharton.espresso:espresso:1.1-r2'
}
```

``` gradle
defaultConfig {
    minSdkVersion 14
    targetSdkVersion 19

    testInstrumentationRunner "com.google.android.apps.common.testing.testrunner.GoogleInstrumentationTestRunner"
}
```

## Adding the Gson library

describe what Gson is and what it's for.

Find Gson at search.maven.org
Copy the groupId, artifactId and version
Addd to build file
Sync build files.

``` gradle
dependencies {
  compile 'com.android.support:support-v4:18.0.0'
    compile 'com.google.code.gson:gson:2.2.4'
}
```

## Add Sample Data

Provide files to add for sample data.

## Create Adapter

``` java
public class PetsAdapter extends ArrayAdapter<Pet> {

    public PetsAdapter(Context context, List<Pet> objects) {
        super(context, 0, objects);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        return super.getView(position, convertView, parent);
    }
}
```

## Create the adapter test

``` java
public class PetsAdapterTest extends InstrumentationTestCase {

    Context mContext;
    PetsAdapter mAdapter;
    List<Pet> mPets;

    public void setUp() throws Exception {
        super.setUp();

        mContext = getInstrumentation().getTargetContext();
        mPets = SampleDataUtils.getSamplePets(mContext);
        mAdapter = new PetsAdapter(mContext, mPets);
    }

    public void testGetCount_returnsCorrectCount() {
        int expected = mPets.size();
        int actual = mAdapter.getCount();

        assertEquals(expected, actual);
    }
}
```

## Run the tests

blah blah blah

## Add the layout

### Write a test to verify the name

``` java
public void testGetView_showsPetName() throws Exception {
    String actualName = mPets.get(0).name;

    View v = mAdapter.getView(0, null, new FrameLayout(mContext));
    TextView name = (TextView) v.findViewById(R.id.name);

    assertEquals(actualName, name.getText());
}
```

### Create the view