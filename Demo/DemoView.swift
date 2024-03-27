//
//  Created by Shawn McKee on 3/14/24.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI
import DurableGuide

struct DemoView: View {
    
    @State private var customAppearance = false
    
    // A good practice is to provide constants, somewhere, for all the Guide Callout IDs...
    private let START_GUIDE_CALLOUT = "start_callout"
    private let GEAR_GUIDE_CALLOUT = "gear_callout"
    private let APPEARANCE_GUIDE_CALLOUT = "appearance_callout"
    private let RESET_GUIDE_CALLOUT = "reset_callout"

    
    var body: some View {
        buildDemoView()
            .onAppear {
                GuideCallout(START_GUIDE_CALLOUT).show(afterDelay: 0.75) // Begin by showing the start guide on first appearance.
            }
            .enableGuideCallouts(withAppearance: customAppearance ? CustomGuideAppearance() : GuideAppearance()) // This is how we enable guides to appear and set their appearance.
    }
    
    
    @ViewBuilder
    private func buildDemoView() -> some View {
        NavigationStack {
            ZStack {
                VStack {
                    buildDemoTitle()
                    buildStartButton()
                    buildResetButton()
                    buildCurrentAppearanceSetting()
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                buildGrearToolbarItem()
                buildAppearanceToolbarItem()
            }
        }
    }
    
    @ViewBuilder
    private func buildDemoTitle() -> some View {
        Image(systemName: "bubble.fill")
            .font(.system(size: 50))
            .imageScale(.large)
            .foregroundStyle(.tint)
            .onTapGesture {
                resetDemo() // For fun, let's make tapping on the bubble graphic also reset the demo. (Try tapping it fast!)
            }
        Text("DurableGuide").fontWeight(.heavy)
        Text("Swift Package Demo")
            .padding(.bottom, 20)

    }
    
    
    @ViewBuilder
    private func buildStartButton() -> some View {
        Button("Start Showing Guides") {
            // To chain multiple guides together, simply provide an `onDismiss` handler
            // and show the next guide when the curreng guide is dismissed...
            GuideCallout(GEAR_GUIDE_CALLOUT).show() {
                GuideCallout(APPEARANCE_GUIDE_CALLOUT).show() {
                    GuideCallout(RESET_GUIDE_CALLOUT).show(afterDelay: 0.5) // Here, we delay the last guide for effect.
                }
            }
        }
        .frame(width: 250)
        .buttonStyle(BlueButton())
        .with(GuideCallout(START_GUIDE_CALLOUT)
            .title("Start Here")
            .message("Tap this button to show the first Guide Callout.\n\n(This is an example of a Guide Callout with a **title** and a **message**. **Markdown** can also be used in the text for _basic styling_.)")
        )
    }
    
    
    @ViewBuilder
    private func buildResetButton() -> some View {
        Button("Reset Demo") {
            resetDemo()
        }
        .with(GuideCallout(RESET_GUIDE_CALLOUT)
            .title("Restart the Demo")
            .message("You may have noticed this last Callout appeared after a slight delay (**`0.5`** seconds). This can be specified when showing a Callout. See the demo app code for details.\n\nNotice, too, that Callouts can be placed above views like this one is.\n\nTap the **“Reset Demo”** button to reset the demo to the beginning.")
            .placement(.above)
        )
        .frame(width: 150)
        .buttonStyle(PlainButtonStyle())
        .foregroundStyle(.tint)
        .padding()
    }
    
    
    @ViewBuilder
    private func buildCurrentAppearanceSetting() -> some View {
        Text("(Appearance: **\(customAppearance ? "Custom" : "Default")**)")
            .padding()
    }
    
    @ToolbarContentBuilder
    func buildGrearToolbarItem() -> some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {} label: {
                Image(systemName: "gearshape.fill")
                    .foregroundStyle(.tint)
            }
            .with(GuideCallout(GEAR_GUIDE_CALLOUT)
                .title("A Toolbar Button Callout")
                .message("Virtually any SwiftUI view can have a Guide Callout (including toolbar items like this one) by simply adding the **`.with(GuideCallout(...))`** view modifier.\n\nGuide Callouts can be chained together, too. **Dismiss this guide** with its **Close Button** to automatically show the next one.")
            )
        }
    }


    @ToolbarContentBuilder
    func buildAppearanceToolbarItem() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                toggleApperance()
            } label: {
                Image(systemName: "paintpalette.fill")
                    .foregroundStyle(.tint)
            }
            .with(GuideCallout(APPEARANCE_GUIDE_CALLOUT)
                .title("Appearance Toggle")
                .message("Guides can have a custom appearance. **Tap this toggle at any time** to see it switch appearances.\n\nNotice that the position of a view’s Callout will adjust to appear within the available screen space depending on where the view is located.")
            )
        }
    }


    func toggleApperance() {
        customAppearance.toggle()
        GuideAppearance.set(customAppearance ? CustomGuideAppearance() : GuideAppearance())
    }

    func resetDemo() {
        customAppearance = false
        GuideAppearance.set(GuideAppearance())
        GuideCallout(START_GUIDE_CALLOUT).show()
    }
}


/// An internal, custom button style used by our demo...
struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.label
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
                .background(Capsule().fill(.tint))
                .foregroundStyle(.white)
        }
    }
}
