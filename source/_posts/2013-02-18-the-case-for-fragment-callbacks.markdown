---
layout: post
title: The case for Fragment Callbacks
categories:
- Android
- Android Snippets
- Fragments
status: publish
type: post
---
Fragment are a great addition to Android.  They allow reusability of sections of your views at the controller layer, and they also provide better encapsulation of your app's logic.  This can really help developers speed up code development and also keep their code clean, which makes it easier to maintain.  All of these benefits are available if you follow a few guidelines when developing your code.

One of the biggest mistakes that I see developers make, particularly those coming from other platforms, is casting the parent activity.  The Fragment API provides methods for communicating with the parent activity because there are many things, like navigation, that should not be handled by the Fragment.  This requires a mechanism for the Fragment to notify the parent Activity when certain activities occur.

One of the obvious solutions is to cast the result of getActivity() to the appropriate class, then call the appropriate method.

	mButton.setOnClickListener(new View.OnClickListener() {
	  public void onClick(View v) {
	    ((MyActivity) getActivity()).chooseItem();
	  }
	});

<!-- more -->

There are many problems with this approach, but the main one for me is that it completely negates the advantages of using Fragments.  This results in tightly coupled code since the Fragment can only really be a child of a single Activity, and any modification of the parent would require a modification of the Fragment.

This is where callback interfaces come into play.  The recommended way to accomplish this parent notification, and the way Google does it in many of their apps, it using callback interfaces.  This is really nothing more than an Interface defined in the Fragment to be called when certain events occur.

The example below shows this technique, including dummy callbacks so you don't have to check mCallbacks for null every time.  This was partially taken from the Google I/O 2012 source code, so it comes complete with Google's seal of approval.

	public interface Callbacks {
		void onNoteSelected(Integer noteId);
	}

	private static Callbacks sDummyCallbacks = new Callbacks() {
		@Override
		public void onNoteSelected(Integer noteId) {
		}
	};

	private Callbacks mCallbacks = sDummyCallbacks;

	@Override
	public void onAttach(Activity activity) {
		super.onAttach(activity);
		if (!(activity instanceof Callbacks)) {
			throw new ClassCastException("Activity must implement fragment's callbacks.");
		}
		mCallbacks = (Callbacks) activity;
	}

	@Override
	public void onDetach() {
		super.onDetach();
		mCallbacks = sDummyCallbacks;
	}
	
Using Fragment callbacks will help you write cleaner, more maintainable, and flexible code.  I've found that, after adopting this pattern, my code is much easier to read and much more reliable.
