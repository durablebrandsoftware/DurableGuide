//
//  Created by Shawn McKee on 3/14/24.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI
import DurableGuide

class CustomGuideAppearance: GuideAppearance {
        
    override func calloutBackgroundColor(forColorScheme colorScheme: ColorScheme) -> Color {
        return .accentColor
    }

    override func calloutForegroundColor(forColorScheme colorScheme: ColorScheme) -> Color {
        return .white
    }

    override func calloutOutlineColor(forColorScheme colorScheme: ColorScheme) -> Color {
        return .white
    }
    
    override open func calloutShadowColor(forColorScheme colorScheme: ColorScheme) -> Color {
        return .accentColor.opacity(0.75)
    }

    public override init() {
        super.init()
        calloutOutlineSize = 3
        calloutShadowSize = 15
    }
}
