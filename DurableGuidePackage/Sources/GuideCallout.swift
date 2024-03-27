//
//  Created by Shawn McKee on 3/14/24.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI


/// The struct that represents a Guide Callout. This struct provides various properties and
/// functionality for working with callouts, including the ability show and dismiss them.
public struct GuideCallout {
    
    /// Every Callout must have a unique ID to reference it by.
    public var id: String
    
    /// The placement of the Callout next to the view. Currently
    /// there are only two options: `.below` and `.above`, and it defaults to `.below`.
    public var placement: GuideCalloutPlacement = .below
    
    /// The title that should appear in the Callout.
    public var title: String? = nil
    
    /// The text message to display in the Callout.
    public var message: String? = nil

    /// The designated initializer for a `GuideCallout`. Every Callout must have at least an ID.
    public init(_ id: String) {
        self.id = id
    }
    
    /// A convenience function that lets you set the `placement` and then returns the updated `GuideCallout`
    /// so that you can chain other setter calls together when initiating a `GuideCallout`. This makes it convenient when
    /// attaching a Callout to a view using the `.with(GuideCallout(...))` view modifier.
    public func placement(_ placement: GuideCalloutPlacement) -> GuideCallout {
        var callout = self
        callout.placement = placement
        return callout
    }
    
    /// A convenience function that lets you set the `title` and then returns the updated `GuideCallout`
    /// so that you can chain other setter calls together when initiating a `GuideCallout`. This makes it convenient when
    /// attaching a Callout to a view using the `.with(GuideCallout(...))` view modifier.
    public func title(_ title: String) -> GuideCallout {
        var callout = self
        callout.title = title
        return callout
    }

    /// A convenience function that lets you set the `message` and then returns the updated `GuideCallout`
    /// so that you can chain other setter calls together when initiating a `GuideCallout`. This makes it convenient when
    /// attaching a Callout to a view using the `.with(GuideCallout(...))` view modifier.
    public func message(_ message: String) -> GuideCallout {
        var callout = self
        callout.message = message
        return callout
    }

    /// Call this method to show the Callout. Optionally, you can have the Callout wait for the `afterDelay` time interval
    /// before it's displayed. This can be helpful for making sure any animations have completed before showing the Callout. Also,
    /// you can provide an `onDismiss` handler that gets called when the user dismisses the Callout, or if it is closed programmatically
    /// with dismissal (see the `close()` function).
    public func show(afterDelay delay: TimeInterval = 0, onDismiss: @escaping (() -> Void) = {}) {
        guideDisplayState.calloutDelay = delay
        guideDisplayState.currentCallout = nil
        guideDisplayState.pendingCalloutID = id
        GuideCallout.onDismissGuideCallout = onDismiss
    }
    
    /// Call this to programmatically close the callout. Optionally, you can pass `true` to the
    /// withDismissal` parameter to trigger the `onDismiss` handler if one was provided when
    /// the Callout was shown (see the `show()` function).
    public func close(withDismissal: Bool = false) {
        if let currentGuide = guideDisplayState.currentCallout, currentGuide.id == id {
            GuideCallout.closeCurrent()
            if (withDismissal) {
                GuideCallout.onDismissGuideCallout()
            }
        }
    }

    /// An internal function used by the framework to manage the automatic removal of the Callout.
    func remove() {
        close()
        GuideCallout.list[id] = nil
    }

    /// An internal convenience function used to close the current Callout without knowing the ID.
    static func closeCurrent() {
        guideDisplayState.currentCallout = nil
        guideDisplayState.pendingCalloutID = nil
    }
    
    
    /// The internal dictionary used for tracking known callouts.
    static var list = [String: GuideCalloutInfo]()
    
    /// The saved `onDismiss` handler to be called when the Callout is dismissed.
    static var onDismissGuideCallout: () -> Void = {}
    
}




