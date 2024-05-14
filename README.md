# **`DurableGuide`** Swift Package

## Overview
An onboarding library for easily adding **guided callout visuals** to virtually any SwiftUI `View` on the screen. Callouts can be placed `.above` and `.below` views, can be shown and dismissed as needed, and will position themselves automatically within the screen to point to a view, regardless of where the `View` is located.

<img src="README_assets/appearance.gif" alt="lightmode" width="400"/>
<br/><br/>

**WARNING/NOTES:**
* This is a **PRE-RELEASE VERSION**, not fully tested for production apps. 


## Installation
This code is provided as a **Swift Package** that you can add to your Xcode project's "Package Dependencies", under your Project Settings, using the following URL:

<code>https://github.com/durablebrandsoftware/DurableGuide/DurableGuidePackage</code>

Once installed, add the following import to your Swift source files to access its features:

`import DurableGuide`


## Enabling Guides in Your App

To allow Guide Callouts to be displayed in your app, you’ll need to add a single modifier to your app's root view:

```
.enableGuideCallouts()
```

Typically you'll want to add this modifier to your app’s main content view and forget about it:

```
import SwiftUI
import DurableGuide

@main
struct GuidedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .enableGuideCallouts()
        }
    }
}
```

However, the modifier can be targeted to specific full-screen views if, for example, you only need guides to appear in certain areas of your app, or you need to have different appearances for your guides in different areas.

This view modifier takes a subclass `GuideAppearance` that lets you override and customize the appearance of the Guide Callouts as needed. See the `CustomGuideAppearance` subclass in the demo app for an example.

```
.enableGuideCallouts(withAppearance: CustomGuideAppearance())
```


## Attaching Callouts to Views

Virtually any SwiftUI `View` can have a callout. Simply add the new `.with(GuideCallout(..))` modifier to the view, passing an instance of `GuideCallout` to it containing the callout’s unique ID, and the `title` and `message` you want to display.

```
.with(GuideCallout("unique-callout-id")
    .title("Calout Title")
    .message("The detailed message of your Callout.")
)
```

`GuideCallout` is a `struct` that comes with some chainable functions for initializing the callout at instantiation. In the example above, both the `title(..)` and the `message(...)` functions were called to set the `title` and `message` of the callout, both return the updated instance so that it could be passed on to the view modifier.

Make sure to remember the `id` you pass to the initializer, and make sure it’s unique. You’ll need it later to display the callout. For this reason, it’s a good idea to use constant variables defined somewhere for your callouts, instead of a literal string as shone here (`"unique-callout-id"`), so that you can use them in multiple places in your code.

This is all you need to do to attach a callout to a view.




## Displaying Callouts

To display a callout, all you need to do is create an instance of the `GuideCallout` struct initializing it with the callout’s `id`, and use its `show(...)` function. One common place to trigger the display of a callout, for example, is in a view’s `.onAppear` as shown here:

```
.onAppear {
    GuideCallout("unique-callout-id").show()
}
```

You can see why the `id` you used when you attached the callout to the view is important. Again, in a real app you’ll want to define constants for your IDs and use them instead.

The `show(...)` function has two optional parameters. The first is a `TimeInterval` that allows you to delay the appearance of the callout for a brief moment:

```
.onAppear {
    GuideCallout("unique-callout-id").show(afterDelay: 0.75)
}
```

This can be useful, for example, if you need to make sure animations are complete and the view is in it's final resting place before showing its callout.

The second optional parameter is a closure, called `onDismiss`, that will get called if the user dismisses the callout by tapping its close button. This handler can be helpful if you want something specific to happen when you know the user specifically dismissed the callout, such as showing another callout to guide the user further, as discussed next...

## Chaining Guided Callouts

There may be features in your app that could benifit from a few callouts to show people the information they need. **Be careful with this.** You don’t want to annoy your users. But sometimes it can be helpful to show a few callouts, one after the other.

To chain callouts together, you can use the `onDismiss` handler of the `show()` function to display the next callout. This example shows a chain that gets triggered from a view’s tap gesture:

```
.onTapGesture {
    GuideCallout("first-callout-id").show() {
        GuideCallout("second-callout-id").show() {
            GuideCallout("third-callout-id").show()
        }
    }
}
``` 

## Dismissing Callouts

Users can dismiss a callout by tapping its close button. As mentioned, this will trigger the `onDismiss` handler if one was provided.

You can also dismiss callouts programmatically by calling the `close(...)` function on the callout’s `GuideCallout` struct.

```
.onTapGesture {
    GuideCallout("unique-callout-id").close()
}
```

The `close(...)` function has one optional `Bool` parameter called `withDismissal` that allows you to simulate a user dismissal, triggering the `onDismiss` handler if one was provided. The default value for `withDismissal` is `false`.

```
.onTapGesture {
    GuideCallout("unique-callout-id").close(withDismissal: true)
}
```

And finally, callouts will be dismissed automatically for you if the view that it is attached to is removed from the view hierarchy. 

## Demo

There is a complete Xcode demo project available [**here**](https://github.com/durablebrandsoftware/DurableGuideDemo) that you can compile and run to see all of this and more in action:

https://github.com/durablebrandsoftware/DurableGuideDemo

 See the `DemoView.swift` file for in that project details.


