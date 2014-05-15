---
layout: post
title: "Using Custom Compound Views in Android"
date: 2014-05-14 09:26
comments: true
categories: 
 - Android
 - development
published: true
---
On a recent client app, I ran into a situation where I needed an arbitrary number of EditText fields based on a selected value, where the user could enter people's information.  My initial thought was to put this logic in my Fragment, just adding EditTexts to a LinearLayout container as the selected value changes, but that bloated my Fragment, and didn't allow for much reuse.

{% img center /images/posts/compound_views/compound_friend_view.png %}

This was a perfect opportunity to encapsulate this interaction functionality in a custom view, which would be reusable throughout the app (required in two places so far), and would allow me to easily test the encapsulated functionality.

<!-- more -->

# What Are Custom Compound Views

The Android framework provides many Views and Layouts, but sometimes developers need to create their own.  Sometimes these are extensions of the built in class to add functionality, like supporting custom fonts and letter spacing in TextViews.  Other times these are simply because a built in view doesn't exist for the desired functionality, like radial dials.

What I'm talking about are custom compound views, views that are made up of multiple other views, whether those are builtin or custom, to encapsulate complex interaction and functionality.

I use compound views in cases where a full fledged Fragment is more than I need, but I want reusable, testable components.  The example I explained above is a great example of that.  Since the code for that was for a client project, I've created a simple project to demonstrate creating and using custom compound views available [here](https://github.com/rharter/CompoundViews).

# The Custom View

In this example, we want a custom view that adds EditTexts so that the user can enter data for an arbitrary number of items.  In a custom view, this can easily be done with a simple container view (LinearLayout) that sets the appropriate number of EditTexts, and allows you to easily fetch a list of names.  Here's the code:

``` java

/**
 * A custom compound view that displays an arbitrary
 * number of text views to enter your friends names.
 */
public class FriendNameView extends LinearLayout {

    private int mFriendCount;
    private int mEditTextResId;

    public FriendNameView(Context context) {
        this(context, null);
    }

    public FriendNameView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public FriendNameView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        setOrientation(VERTICAL);
    }

    public int getFriendCount() {
        return mFriendCount;
    }

    public void setFriendCount(int friendCount) {
        if (friendCount != mFriendCount) {
            mFriendCount = friendCount;

            removeAllViews();
            for (int i = 0; i < mFriendCount; i++) {
                addView(createEditText());
            }
        }
    }

    private View createEditText() {
        View v;
        if (mEditTextResId > 0) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            v = inflater.inflate(mEditTextResId, this, true);
        } else {
            EditText et = new EditText(getContext());
            et.setHint(R.string.friend_name);
            v = et;
        }
        return v;
    }

    public int getEditTextResId() {
        return mEditTextResId;
    }

    public void setEditTextResId(int editTextResId) {
        mEditTextResId = editTextResId;
    }

    /**
     * Returns a list of entered friend names.
     */
    public List<String> getFriendNames() {
        List<String> names = new ArrayList<>();
        for (int i = 0; i < getChildCount(); i++) {
            View v = getChildAt(i);
            if (v instanceof EditText) {
                EditText et = (EditText) v;
                names.add(et.getText().toString());
            }
        }
        return names;
    }
}
```

When the user sets the number of friends with `setFriendCount(int)`, we reset the number of child EditText fields based on that number.  This can be done with a custom layout resource, but will default to a simple EditText.

When we want to retrieve the list of names the user has entered, we don't care about any of the internal structure of the custom view since we can just call `getFriendNames()` and the view will compile a list of names.

That's all there is to this simple example.  As a special side effect, since this view is just made up of a LinearLayout (the super class) and EditText views which already know how to save and restore their state, we don't have to do any state handling.

# Including the Custom View in Layouts

When you want to use your custom view in your Activity or Fragment layouts, you can simply add some XML like you would any other view.

``` xml
<com.ryanharter.android.compoundviews.app.views.FriendNameView
    android:id="@+id/friend_names"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"/>
```

Then you access it just like any other using `findViewById(int)`.

``` java
mFriendNameView = (FriendNameView) findViewById(R.id.friend_names);
```

In our MainActivity we simply set the friend count when the NumberPicker value changes, and call `getFriendNames()` when we want to retrieve the list of names.

``` java
mFriendCountPicker.setOnValueChangedListener(new OnValueChangeListener() {
    @Override public void onValueChange(NumberPicker picker, int oldVal, int newVal) {
        mFriendNameView.setFriendCount(newVal);
    }
});

mCountFriendsButton.setOnClickListener(new OnClickListener() {
    @Override public void onClick(View v) {
        List<String> names = mFriendNameView.getFriendNames();
        Intent i = new Intent(MainActivity.this, FriendCountActivity.class);
        i.putStringArrayListExtra("names", new ArrayList<String>(names));
        startActivity(i);
    }
});
```

Though this is a contrived example, compound custom views are a great way to encapsulate functionality that would otherwise be strewn throughout your Activities and Fragments.  They provide testable, reusable code that makes for more stable apps.  I encourage you to see where you can use custom compound views in your apps, and share them with other devs if you can and they would be useful.

Get the code for the sample app on [Github](https://github.com/rharter/CompoundViews).