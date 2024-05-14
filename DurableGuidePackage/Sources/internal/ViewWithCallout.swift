//
//  Created by Shawn McKee on 3/14/24.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI

private var calloutSettledTimer: Timer? = nil

/// An internal wrapper view to enable views that can present guide callouts.
struct ViewWithCallout<OriginalView: View, GuideContentView: View>: View {
    
    @EnvironmentObject private var guideDisplayState: GuideDisplayState

    let id: String
    let placement: GuideCalloutPlacement
    let offset: CGPoint
    @ViewBuilder let guideContentView: () -> GuideContentView
    @ViewBuilder let originalView: OriginalView
    
    public var body: some View {
        originalView
            .background(
                // The trick we use to determing the actual placement of a view on the screen
                // (and keep it up-to-date) without affecting any layout of the views around it,
                // is to put a `GeometryReader` around a clear background view and use the
                // geometry of that clear view as the view's frame...
                GeometryReader { geometry in
                    generateClearBackground(withGeometry: geometry)
                }
            )
            .onDisappear {
                GuideCallout(id).remove()
            }
    }
    
    @ViewBuilder
    public func generateClearBackground(withGeometry geometry: GeometryProxy) -> some View {
        var frame = geometry.frame(in: .global)
        frame.origin.x += offset.x
        frame.origin.y += offset.y
        var guide = GuideCallout.list[id] ?? GuideCalloutInfo(id: id, view: AnyView(guideContentView()))
        guide.placement = placement
        guide.offset = offset
        guide.sourceViewRect = frame
        GuideCallout.list[id] = guide

        return Color.clear
    }

}


