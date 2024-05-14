//
//  Created by Shawn McKee on 3/14/24.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI

/// Provides various appears settings for how the Guide Callouts should be displayed. Apps can override this
/// class and pass an instance of it to the `.enableGuides(withAppearance:)` view modifier to
/// override appearance settings that appropriate for the app's design. By default, Callouts will
/// be display as light or dark variations depending on the system's current light or dark mode setting.
open class GuideAppearance {
    
    /// The size of the outline drawn around the Callout. Default value is 1.
    /// A custom value can be provided by overriding the defualt class initializer of a subclass and setting it there.
    public var calloutOutlineSize: Double = 1

    
    /// The size (or spread) of the shadow around the Callout. Default value is 10.
    /// A custom value can be provided by overriding the defualt class initializer of a subclass and setting it there.
    public var calloutShadowSize: Double = 10


    /// The background color used for Guide Callouts. Subclass can override this function to return
    /// a custom color for the background, taking into account the given `ColorScheme` (light or dark) as needed.
    open func calloutBackgroundColor(forColorScheme colorScheme: ColorScheme) -> Color {
#if os(macOS)
        return Color(NSColor.windowBackgroundColor)
#else
        return Color(UIColor.secondarySystemBackground)
#endif
    }

    /// The foreground color used for Guide Callouts. Subclass can override this function to return
    /// a custom color for the foreground (text, etc.), taking into account the given `ColorScheme` (light or dark) as needed.
    open func calloutForegroundColor(forColorScheme colorScheme: ColorScheme) -> Color {
        return .primary
    }

    /// The  color used to draw the outline around Guide Callouts. Subclass can override this function to return
    /// a custom color for the outline, taking into account the given `ColorScheme` (light or dark) as needed.
    open func calloutOutlineColor(forColorScheme colorScheme: ColorScheme) -> Color {
        return .secondary
    }

    /// The  color used to render the shadow under Guide Callouts. Subclass can override this function to return
    /// a custom color for the shadow (including opacity), taking into account the given `ColorScheme` (light or dark) as needed.
    open func calloutShadowColor(forColorScheme colorScheme: ColorScheme) -> Color {
        return colorScheme == .light ? .black.opacity(0.2) : .white.opacity(0.35)
    }

    /// A static convenience function that allows you to chage the `GuideAppearance` once it has been set.
    public static func set(_ appearance: GuideAppearance) {
        guideAppearance = appearance
        guideDisplayState.reshowCurrentCallout()
    }

    public init() {}
}
