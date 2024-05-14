//
//  Created by Shawn McKee on 3/14/24.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI

public extension View {
    
    /// Enables Guide Callouts within the app. This modifier must be added to a full-screen view in the app. Typically this should
    /// be applied to the app's main view, but can also be targeted to other full-screen views, if guides will be limited to certain
    /// areas of the app, or you would like to have different apperances for the guides in different areas of the app.
    @ViewBuilder
    func enableGuideCallouts(withAppearance appearance: GuideAppearance = GuideAppearance()) -> some View {
        guideAppearance = appearance
        return GuideDisplay {
            self
        }
        .environmentObject(guideDisplayState)
    }

    
    /// Attaches a Guide Callout to the `View`, based on the given `GuideCallout`.
    func with(_ guide: GuideCallout) -> some View {
        self.withGuideCallout(guide.id, placement: guide.placement, title: guide.title, message: guide.message, offset: guide.offset) {
            EmptyView() // Currently, a `customContentView` parameter is required for the `.withGuideCallout` modifier, but we're not support custom views yet. So simply passing an `EmptyView`.
        }
    }

    /// Internal helper modifier for attaching a callout that has a formatted `title` and `message` views. This is currently used by the public `.with(_ guide:)` modifier. We'll be cleaning this up when we support custom views.
    @ViewBuilder
    private func withGuideCallout(_ id: String, placement: GuideCalloutPlacement = .below, title: String? = nil, message: String? = nil, offset: CGPoint, @ViewBuilder customContentView: @escaping () -> some View) -> some View {
        ViewWithCallout(id: id, placement: placement, offset: offset, guideContentView: {
            VStack(alignment: .leading) {
                GuideCalloutTextView(title: title, message: message)
                customContentView()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }, originalView: {self})
    }

    /// UNTESTED: Future support for showing Callouts with a completely custom content view only. We'll be cleaning this up when we support custom views.
    @ViewBuilder
    private func withGuideCallout(_ id: String, placement: GuideCalloutPlacement = .below, @ViewBuilder guideContentView: @escaping () -> some View) -> some View {
        ViewWithCallout(id: id, placement: placement, offset: CGPoint.zero, guideContentView: guideContentView) {
            self
        }
    }

}


/// An internal helper view for rendering the Callout's title and message.
fileprivate struct GuideCalloutTextView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var title: String? = nil
    var message: String? = nil

    public var body: some View {
        VStack(alignment: .leading) {
            if let title = title {
                Text(.init(title))
                    .font(.system(.title3, weight: .bold))
                    .foregroundColor(guideAppearance.calloutForegroundColor(forColorScheme: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let message = message {
                Text(.init(message))
                    .font(.system(.body, weight: .light))
                    .foregroundColor(guideAppearance.calloutForegroundColor(forColorScheme: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
}
