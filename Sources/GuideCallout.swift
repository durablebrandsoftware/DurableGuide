//
//  Created by Shawn McKee on 3/14/24.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI


/// The struct that represents a callout. This struct provides various properties and
/// functionality for working with callouts, including the ability show and dismiss them.
public struct GuideCallout {
    
    /// Every callout must have a unique ID to reference it by.
    var id: String
    
    /// The placement of the callout next to the view. Currently
    /// there are only two options: `.below` and `.above`, and it defaults to `.below`.
    var placement: GuideCalloutPlacement = .below
    
    /// The title that should appear in the callout.
    var title: String? = nil
    
    /// The text message to display in the callout.
    var message: String? = nil

    /// The the offset to place the callout, if any.
    var offset: CGPoint = CGPoint.zero

    /// The designated initializer for a `GuideCallout`. Passing the `id` of an existing callout
    /// will return an instance of that callout.
    public init(_ id: String) {
        self.id = id
    }
    
    /// A convenience function that lets you set the `placement` and then returns the updated `GuideCallout`
    /// so that you can chain other setter calls together when initiating a `GuideCallout`. This function makes it convenient when
    /// attaching a callout to a view using the `.with(GuideCallout(...))` view modifier.
    public func placement(_ placement: GuideCalloutPlacement) -> GuideCallout {
        var callout = self
        callout.placement = placement
        return callout
    }
    
    /// A convenience function that lets you set the `title` and then returns the updated `GuideCallout`
    /// so that you can chain other setter calls together when initiating a `GuideCallout`. This function makes it convenient when
    /// attaching a callout to a view using the `.with(GuideCallout(...))` view modifier.
    public func title(_ title: String) -> GuideCallout {
        var callout = self
        callout.title = title
        return callout
    }

    /// A convenience function that lets you set the `message` and then returns the updated `GuideCallout`
    /// so that you can chain other setter calls together when initiating a `GuideCallout`. This function makes it convenient when
    /// attaching a callout to a view using the `.with(GuideCallout(...))` view modifier.
    public func message(_ message: String) -> GuideCallout {
        var callout = self
        callout.message = message
        return callout
    }

    /// A convenience function that lets you set the callout's `offset` and then returns the updated `GuideCallout`
    /// so that you can chain other setter calls together when initiating a `GuideCallout`. This  function makes it convenient when
    /// attaching a callout to a view using the `.with(GuideCallout(...))` view modifier.
    public func offset(_ offset: CGPoint) -> GuideCallout {
        var callout = self
        callout.offset = offset
        return callout
    }

    /// Call this function to show the callout. Optionally, you can have the callout wait for the `afterDelay` time interval
    /// before it's displayed. This can be helpful for making sure any animations have completed before showing the callout. Also,
    /// you can provide an `onDismiss` handler that gets called when the user dismisses the callout, or if it is closed programmatically
    /// with dismissal (see the `close()` function).
    public func show(afterDelay delay: TimeInterval = 0, onDismiss: @escaping (() -> Void) = {}) {
        guideDisplayState.calloutDelay = delay
        guideDisplayState.currentCallout = nil
        guideDisplayState.pendingCalloutID = id
        GuideCallout.onDismissGuideCallout = onDismiss
    }
    
    /// Call this function to keep showing the callout until it has been dismissed by the user, either with the callout's close button, or
    /// by some other action in your UI where you have called the `dismiss()` function specifically.
    ///
    /// This is a useful way to show callouts that you want to stop appearing once you know the user has seen it and dismissed it.
    public func showUntilDismissed(afterDelay delay: TimeInterval = 0, onDismiss: @escaping (() -> Void) = {}) {
        if count(forState: "\(id).dismissed") > 0 {
            close(withDismissal: true)
            return
        }
        show(afterDelay: delay, onDismiss: onDismiss)
    }
    
    /// Call this function to keep showing the callout until you know user has "acted upon" the guidance of the callout in some way, usually by them doing
    /// something specific in the app that is related to the callout. For example, you might want to keep showing a callout for button until the user taps on that button,
    /// in which case you would call the callout's `actUpon()` function (see below) in the button's action to let the callout know it has been "acted upon."
    ///
    /// This is a useful way to show callouts that you want to stop appearing once the user has done something specific in the app that would
    /// indicate the user doesn't need the guidance of the callout any longer.
    public func showUntilActedUpon(afterDelay delay: TimeInterval = 0, onDismiss: @escaping (() -> Void) = {}) {
        if count(forState: "\(id).actedUpon") > 0 {
            return
        }
        show(afterDelay: delay, onDismiss: onDismiss)
    }
    
    /// Call this function to indicate that the guidance of the callout has been "acted upon" in some way, so that the callout will stop appearing
    /// whenever the `showUntilActedUpon(...)` function is used to show the callout.
    public func actUpon() {
        incrementCount(forState: "\(id).actedUpon")
        close()
    }
    
    /// Returns whether or not the `actUpon()` function has ever been called for this callout.
    public var hasBeenActedUpon: Bool {
        return count(forState: "\(id).actedUpon") > 0
    }

    /// Call this to close a callout as if it had been specifically dismissed by the user. This will track that the callout has
    /// been dismissed, and will prevent it from being shown again, when using the `showUntilDismissed(...)` function.
    public func dismiss() {
        close(withDismissal: true)
    }
    
    /// Call this to programmatically close the callout. Optionally, you can pass `true` to the
    /// withDismissal` parameter to trigger the `onDismiss` handler if one was provided when
    /// the callout was shown (see the `show()` function).
    public func close(withDismissal: Bool = false) {
        if let currentGuide = guideDisplayState.currentCallout, currentGuide.id == id {
            GuideCallout.closeCurrent()
            if (withDismissal) {
                incrementCount(forState: "\(id).dismissed")
                GuideCallout.onDismissGuideCallout()
            }
        }
    }
    
    /// A convenience static function that lets you close the current callout without knowing the ID.
    public static func closeCurrent() {
        guideDisplayState.currentCallout = nil
        guideDisplayState.pendingCalloutID = nil
    }
    
    /// Resets all the internal state for all callouts, allowing those that have been dismissed or acted upon to start
    /// appearing again. This is helpful during development and testing, but you might also want to provide the user
    /// the option to reset callouts, too, so that they can get the benefit of their guidance again if they want.
    public static func resetAll() {
        UserDefaults.standard.setValue([:], forKey: "callout.settings")
    }

    /// For determining the number of times the given state value has been counted.
    /// Used internally for various tracking purpose.
    private func count(forState key: String) -> Int {
        if let value = state[key] as? Int {
            return value
        }
        return 0
    }
    
    /// An internal function used by the framework to increment the number of times the given state value has been counted.
    /// Used internally for various tracking purpose.
    private func incrementCount(forState key: String) {
        set(count: count(forState: key) + 1, forState: key)
    }

    /// An internal function used by the framework to set the number of times the given state value has been counted.
    /// Used internally for various tracking purpose.
    private func set(count: Int, forState key: String) {
        var newState = state
        newState[key] = count
        save(state: newState)
    }
    
    /// An internal function used by the framework to access the state beings used for tracking callouts.
    private var state: [String: Any] {
        get {
            var value = UserDefaults.standard.value(forKey: "callout.settings") as? [String: Any]
            if value == nil {
                value = [:]
                
            }
            return value!
        }
    }
    
    /// An internal function used by the framework to save the state being used for tracking callouts.
    private func save(state: [String: Any]) {
        UserDefaults.standard.setValue(state, forKey: "callout.settings")
    }

    /// An internal function used by the framework to manage the automatic removal of the callout.
    func remove() {
        close()
        GuideCallout.list[id] = nil
    }

    /// The internal dictionary used for tracking known callouts.
    static var list = [String: GuideCalloutInfo]()
    
    /// The saved `onDismiss` handler provided to be called when the callout is dismissed.
    static var onDismissGuideCallout: () -> Void = {}
   
    
}




