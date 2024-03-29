//
//  Created by Shawn McKee on 3/14/24.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI

private var guideCalloutSettledTimer: Timer? = nil

/// An internal view used to present a Guide Callout.
struct GuideCalloutView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var guideDisplayState: GuideDisplayState
    
    var id: String
    @State var ready: Bool = false
    @State var offset: CGPoint = CGPoint.zero
    @State var opacity: Double = 0.0
    @State var scale: Double = 0.0

    var body: some View {
        let minAndMaxWidths = minAndMaxWidths()
        
        GeometryReader {geometry in
            ZStack(alignment: .topLeading) {
                if let calloutInfo = getCalloutInfo() {
                    if ready {
                        content(calloutInfo, opacity: opacity, scale: scale)
                    } else {
                        content(calloutInfo, opacity: 0.0)
                    }
                }
            }
            .frame(minWidth: minAndMaxWidths.min, maxWidth: minAndMaxWidths.max)

            .offset(x: offset.x, y: offset.y)
            .onAppear() {
                if let calloutInfo = getCalloutInfo() {
                    guideDisplayState.sourceViewRect = calloutInfo.sourceViewRect
                    guideDisplayState.calloutRect = calloutInfo.calloutRect
                    var start: CGPoint = CGPoint.zero
                    start.x = guideDisplayState.sourceViewRect.origin.x + guideDisplayState.sourceViewRect.size.width/2 - guideDisplayState.calloutRect.size.width/2
                    start.y = guideDisplayState.sourceViewRect.origin.y + guideDisplayState.sourceViewRect.size.height/2 - guideDisplayState.calloutRect.size.height/2
                    offset = start
                    ready = true
                }
            }
            .onChange(of: ready) {
                if let calloutInfo = getCalloutInfo(), ready {
                    guideDisplayState.calloutRect = calloutInfo.calloutRect
                    withAnimation(.bouncy(duration: 0.35, extraBounce: 0.12)) {
                        scale = 1.0
                        opacity = 1.0
                        offset = guideDisplayState.calloutRect.origin
                    }
                }
            }
        }
    }
    
    func minAndMaxWidths() -> (min: CGFloat, max: CGFloat) {
        let minWidth: CGFloat = 330
        let percentage: CGFloat = (guideDisplayState.displayFrame.width < guideDisplayState.displayFrame.width) ? 0.667 : 0.35
        let twoThirdsWidth: CGFloat = (guideDisplayState.displayFrame.width - 16) * percentage
        var maxWidth = minWidth < twoThirdsWidth ? twoThirdsWidth : minWidth
        return (minWidth, maxWidth)
    }
        
    @ViewBuilder
    public func content(_ calloutInfo: GuideCalloutInfo, opacity: Double = 1.0, scale: Double = 1.0) -> some View {
        let closeButtonPadding: CGFloat = 3 + (guideAppearance.calloutOutlineSize/2)
        let closeButtonTopPadding: CGFloat = (calloutInfo.placement == .below ? 11 : 3) + (guideAppearance.calloutOutlineSize/2)
        let shape = GuideCalloutShape(calloutInfo: calloutInfo)
        
        calloutInfo.view
            .padding(.top, calloutInfo.placement == .below ? 17 : 12)
            .padding(.bottom, calloutInfo.placement == .above ? 25 : 15)
            .padding(.trailing, 12)
            .padding(.leading, 12)
            .frame(maxWidth: .infinity)
            .background(
                GeometryReader { geometry in
                    generateClearBackground(withGeometry: geometry)
                }
            )
            .clipShape(shape)
            .shadow(color: guideAppearance.calloutShadowColor(forColorScheme: colorScheme), radius: guideAppearance.calloutShadowSize, x: 0, y: 0)
            .overlay(
                shape
                    .stroke(guideAppearance.calloutOutlineColor(forColorScheme: colorScheme), lineWidth: guideAppearance.calloutOutlineSize)
            )
            .overlay(alignment: .topTrailing) {
                ZStack {
                    Image(systemName: "xmark.circle.fill")
                        .padding(EdgeInsets(top: closeButtonTopPadding, leading: closeButtonPadding, bottom: closeButtonPadding, trailing: closeButtonPadding))
                        .foregroundColor(guideAppearance.calloutOutlineColor(forColorScheme: colorScheme))
                        .opacity(colorScheme == .light ? 0.2 : 0.4)
                }
                .onTapGesture {
                    GuideCallout(id).close(withDismissal: true)
                }
            }
            .scaleEffect(CGSize(width: scale, height: scale))
            .opacity(opacity)
    }

    func getCalloutInfo() -> GuideCalloutInfo? {
        return GuideCallout.list[id]
    }
    
    @ViewBuilder
    public func generateClearBackground(withGeometry geometry: GeometryProxy) -> some View {

        if var calloutInfo = getCalloutInfo() {
            if calloutInfo.placement == .below {
                calculateForBelow(calloutInfo: calloutInfo, geometry: geometry)
            }
            if calloutInfo.placement == .above {
                calculateForAbove(calloutInfo: calloutInfo, geometry: geometry)
            }
        }
        return guideAppearance.calloutBackgroundColor(forColorScheme: colorScheme)
    }
    
    private func calculateForBelow(calloutInfo: GuideCalloutInfo, geometry: GeometryProxy) {
        var xOffset = 0.0
        
        var calloutInfo = calloutInfo
        
        var outlineSize = guideAppearance.calloutOutlineSize
        
        calloutInfo.calloutRect.size.width = geometry.size.width
        calloutInfo.calloutRect.size.height = geometry.size.height
        
        let center = calloutInfo.sourceViewRect.origin.x + calloutInfo.sourceViewRect.size.width/2
        var x = center - (calloutInfo.calloutRect.size.width/2)
        var y = calloutInfo.sourceViewRect.origin.y + calloutInfo.sourceViewRect.size.height + 3
        
        if x < 8 {
            xOffset = x - 8
            x = 8
        }

        if (x + calloutInfo.calloutRect.size.width) > (guideDisplayState.displayFrame.width - 8) {
            x = (guideDisplayState.displayFrame.width - 8) - calloutInfo.calloutRect.size.width
            xOffset = center - (x + calloutInfo.calloutRect.size.width/2)
        }

        calloutInfo.arrowOffset = xOffset
        
#if os(macOS)
        if y < (guideDisplayState.safeArea.top + 4.0 + outlineSize/2.0) {
            y = guideDisplayState.safeArea.top + 4.0 + outlineSize/2.0
        }
#else
        if y < (guideDisplayState.safeArea.top + 8.0 + outlineSize/2.0) {
            y = guideDisplayState.safeArea.top + 8.0 + outlineSize/2.0
        }
#endif

        calloutInfo.calloutRect.origin.x = x
        calloutInfo.calloutRect.origin.y = y

        GuideCallout.list[id] = calloutInfo
    }
    
    private func calculateForAbove(calloutInfo: GuideCalloutInfo, geometry: GeometryProxy) {
        var xOffset = 0.0
        
        var calloutInfo = calloutInfo
        
        calloutInfo.calloutRect.size.width = geometry.size.width
        calloutInfo.calloutRect.size.height = geometry.size.height
        
        let center = calloutInfo.sourceViewRect.origin.x + calloutInfo.sourceViewRect.size.width/2
        var x = center - (calloutInfo.calloutRect.size.width/2)
        var y = calloutInfo.sourceViewRect.origin.y - calloutInfo.calloutRect.size.height - 8
        
        if x < 8 {
            xOffset = x - 8
            x = 8
        }

        if (x + calloutInfo.calloutRect.size.width) > (guideDisplayState.displayFrame.width - 8) {
            x = (guideDisplayState.displayFrame.width - 8) - calloutInfo.calloutRect.size.width
            xOffset = center - (x + calloutInfo.calloutRect.size.width/2)
        }

        calloutInfo.arrowOffset = xOffset
        
#if os(macOS)
        if y < (guideDisplayState.safeArea.top + 3) {
            y = guideDisplayState.safeArea.top + 3
        }
#else
        if y < (guideDisplayState.safeArea.top + 8) {
            y = guideDisplayState.safeArea.top + 8
        }
#endif

        calloutInfo.calloutRect.origin.x = x
        calloutInfo.calloutRect.origin.y = y

        GuideCallout.list[id] = calloutInfo
    }
    
}

public enum GuideCalloutPlacement {
    case above
    case below
}



struct GuideCalloutInfo: Equatable {
    
    var id: String
    var sourceViewRect: CGRect = CGRect.zero
    var placement: GuideCalloutPlacement = .below
    
    var view: AnyView
    var calloutRect: CGRect = CGRect.zero
    var arrowOffset: CGFloat = 0
    
    static func == (lhs: GuideCalloutInfo, rhs: GuideCalloutInfo) -> Bool { lhs.id == rhs.id }
}


struct GuideCalloutShape: Shape {
    
    let calloutInfo: GuideCalloutInfo
    let arrowWidth = 12.0
    let arrowHeight = 8.0
    let cornerRadius = 8.0
    
    func path(in rect: CGRect) -> Path {
        switch calloutInfo.placement {
        case .above:
            return getPathPointingDown(in: rect)
        case .below:
            return getPathPointingUP(in: rect)
        }
    }
    
    private func getPathPointingUP(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let arrowCenter: CGFloat = rect.width/2 + calloutInfo.arrowOffset
        return Path { path in
            path.move(to: CGPoint(x: cornerRadius, y: arrowHeight))
            path.addLine(to: CGPoint(x: arrowCenter - arrowWidth/2, y: arrowHeight))
            path.addLine(to: CGPoint(x: arrowCenter, y: 0))
            path.addLine(to: CGPoint(x: arrowCenter +  arrowWidth/2, y: arrowHeight))

            path.addLine(to: CGPoint(x: width - cornerRadius, y: arrowHeight))
            path.addQuadCurve(to: CGPoint(x: width, y: arrowHeight + cornerRadius),
                              control: CGPoint(x: width, y: arrowHeight))

            path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
            path.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: height),
                              control: CGPoint(x: width, y: height))

            path.addLine(to: CGPoint(x: cornerRadius, y: height))
            path.addQuadCurve(to: CGPoint(x: 0, y: height - cornerRadius),
                              control: CGPoint(x: 0, y: height))

            path.addLine(to: CGPoint(x: 0, y: cornerRadius + arrowHeight))
            path.addQuadCurve(to: CGPoint(x: cornerRadius, y: arrowHeight),
                              control: CGPoint(x: 0, y: arrowHeight))
        }
    }

    private func getPathPointingDown(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let arrowCenter: CGFloat = rect.width/2 + calloutInfo.arrowOffset
        return Path { path in
            path.move(to: CGPoint(x: cornerRadius, y: height - arrowHeight))
            path.addLine(to: CGPoint(x: arrowCenter - arrowWidth/2, y: height - arrowHeight))
            path.addLine(to: CGPoint(x: arrowCenter, y: height))
            path.addLine(to: CGPoint(x: arrowCenter +  arrowWidth/2, y: height - arrowHeight))

            path.addLine(to: CGPoint(x: width - cornerRadius, y: height - arrowHeight))
            path.addQuadCurve(to: CGPoint(x: width, y: height  - arrowHeight - cornerRadius),
                              control: CGPoint(x: width, y: height - arrowHeight))

            path.addLine(to: CGPoint(x: width, y: cornerRadius))
            path.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: 0),
                              control: CGPoint(x: width, y: 0))

            path.addLine(to: CGPoint(x: cornerRadius, y: 0))
            path.addQuadCurve(to: CGPoint(x: 0, y: cornerRadius),
                              control: CGPoint(x: 0, y: 0))

            path.addLine(to: CGPoint(x: 0, y: height - cornerRadius - arrowHeight))
            path.addQuadCurve(to: CGPoint(x: cornerRadius, y: height - arrowHeight),
                              control: CGPoint(x: 0, y: height - arrowHeight))
        }
    }
    
}
