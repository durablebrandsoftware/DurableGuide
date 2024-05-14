//
//  Created by Shawn McKee on 3/14/24.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI

/// An internal view used to present the guides.
struct GuideDisplay<Content: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var guideDisplayState: GuideDisplayState
    
    @ViewBuilder let content: Content

    @State private var timer = Timer.publish(every: 1000, on: .main, in: .common).autoconnect()

    public var body: some View {
        GeometryReader { geometry in
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .overlay {
                    ZStack {
                        if let currentCallout = guideDisplayState.currentCallout {
                            GuideCalloutView(id: currentCallout.id)
                       }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .ignoresSafeArea()
                }
                .onChange(of: geometry.size) {
                    updateGuideDisplay(withGeometry: geometry)
                }
                .onAppear {
                    timer.upstream.connect().cancel()
                    updateGuideDisplay(withGeometry: geometry)
                }
            
                .onChange(of: guideDisplayState.pendingCalloutID) {
                    timer.upstream.connect().cancel()
                    timer = Timer.publish(every: guideDisplayState.calloutDelay, on: .main, in: .common).autoconnect()
                }
                .onReceive(timer) { _ in
                    timer.upstream.connect().cancel()
                    if let pendingCalloutID = guideDisplayState.pendingCalloutID {
                        guideDisplayState.showPendingCallout()
                    }
                }
        }
    }
    
    private func updateGuideDisplay(withGeometry geometry: GeometryProxy) {
        guideDisplayState.displayFrame = geometry.frame(in: .local)
        guideDisplayState.safeArea = geometry.safeAreaInsets
        if let currentCallout = guideDisplayState.currentCallout, guideDisplayState.pendingCalloutID == nil {
            guideDisplayState.pendingCalloutID = currentCallout.id
            guideDisplayState.currentCallout = nil
        }
    }
    
}

/// The internal observable state object for managing and updating test harness state .
class GuideDisplayState: ObservableObject {
    @Published var pendingCalloutID: String? = nil
    
    @Published var currentCallout: GuideCalloutInfo? = nil
    @Published var calloutRect: CGRect = CGRect.zero
    @Published var sourceViewRect: CGRect = CGRect.zero
    
    @Published var displayFrame: CGRect = CGRect.zero
    @Published var safeArea: EdgeInsets = EdgeInsets()
    
    @Published var calloutDelay: TimeInterval = 0.75
    
    func showPendingCallout() {
        if let pendingCalloutID = self.pendingCalloutID {
            currentCallout = GuideCallout.list[pendingCalloutID]
            self.pendingCalloutID = nil
            self.calloutDelay = 0
        }
    }
    
    func reshowCurrentCallout() {
        if let currentCallout = guideDisplayState.currentCallout, guideDisplayState.pendingCalloutID == nil {
            guideDisplayState.currentCallout = nil
            guideDisplayState.pendingCalloutID = currentCallout.id
        }
    }

}
var guideDisplayState = GuideDisplayState()
var guideAppearance = GuideAppearance()




