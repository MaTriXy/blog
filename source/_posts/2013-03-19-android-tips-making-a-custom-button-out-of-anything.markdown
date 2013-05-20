---
layout: post
title: ! 'Android Tips: Making a Custom Button out of Anything'
tags:
- Android
- Android Snippets
- Programming
- Tips
- Tips and Tricks
status: publish
type: post
published: true
comments: true
---
The Android APIs are filled with things that don't quite seem right.  I've always been annoyed by the lack of relationship between interface elements.  For instance, isn't a ListView really just a special case of a GridView with only one column?  Yet GridView and ListView aren't directly related, so we get oddities where I can add header and footer views to a ListView, but not a GridView.

One thing that seems to trip people up is the Button class.  Android has a Button class for text (and images if your not really concerned with formatting them) and an ImageButton class for images.  Like the ListView/GridView situation mentioned earlier, these two buttons are not, in fact, related.  Button inherits from TextView and ImageButton inherits from ImageView.

This tends to trip people up when it comes to seemingly common elements like a button with both image and text centered.

{% img /images/posts/centered-button.png %}

<!-- more -->

I've seen a lot of ridiculous solutions to this, including <a href="http://stackoverflow.com/questions/4817449/how-to-have-image-and-text-center-within-a-button#tab-top" target="_blank">this one</a>, which involve invisible button overlays and complex layouts used in high profile apps.  This can greatly affect performance by added layout complexity and make view management and maintenance extremely difficult.

## Exploring the Button

The Button class is nothing more than a TextView, really.  Go ahead, check the <a title="Button.java" href="https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/java/android/widget/Button.java" target="_blank">source</a>.  What many people don't notice is that the Button's click handling is all covered at the View level.  If you require this type of layout, or any fancy button layout, in fact, there is no need for all of this complexity and magic.

{% img /images/posts/three-buttons.png %}

All three buttons above look and function the same, except that they are laid out slightly differently.

{% codeblock lang:xml %}
<Button
	android:id="@+id/image_button_1"
	android:layout_width="match_parent"
	android:layout_height="wrap_content"
	android:layout_marginTop="15dp"
	android:drawableLeft="@drawable/ic_gear"
	android:text="Button 1" />
{% endcodeblock %}

As you can see, Button 1 is simply a normal Button.  You can use drawable:left (or any other direction + start/end) to add images to buttons, but you don't get a lot of choice as to how it's laid out, aside from what gravity can do.

{% codeblock lang:xml %}
<LinearLayout
	android:id="@+id/image_button_2"
	style="@android:style/Widget.Button"
	android:layout_width="match_parent"
	android:layout_height="wrap_content"
	android:layout_marginTop="15dp"
	android:gravity="center">

	<ImageView
		android:layout_width="wrap_content"
		android:layout_height="wrap_content"
		android:layout_marginRight="5dp"
		android:src="@drawable/ic_gear" />

	<TextView
		android:id="@+id/image_button_2_text"
		android:layout_width="wrap_content"
		android:layout_height="wrap_content"
		android:textColor="@android:color/black"
		android:text="Button 2" />

</LinearLayout>
{% endcodeblock %}

Now for the not so tricky part.  As you can see, Button 2 is just a LinearLayout with the internal items laid out however I want.  In this case, centered in the view.  Adding the style="@android:style/Widget.Button" gets us the standard button background complete with pressed states.  You can add any background you choose (hopefully a <a title="State List Drawables" href="http://developer.android.com/guide/topics/resources/drawable-resource.html#StateList" target="_blank">State-List drawable</a> so you get pressed and focused states) and just treat the LinearLayout as a button.

{% codeblock lang:java %}
final View button2 = findViewById(R.id.image_button_2);
button2.setOnClickListener(new View.OnClickListener() {
	@Override
	public void onClick(View v) {
		toastButton(2);
	}
});
{% endcodeblock %}

The only caveat with this method is that you have to actually set the text directly on the TextView, not the "Button".

It's important to keeps your layouts simple in Android, hopefully this tip can help you do just that.  Go ahead and download the source code for the sample project and check it out.

<a class="button centered" href="/downloads/button_demo.zip">Sample Source</a>