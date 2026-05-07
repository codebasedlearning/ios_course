// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            SensorScreen().tabItem {
                Label("Sensors", systemImage: "1.circle")
            }.tag(0)
            // more Screens...
        }
        // accentColor has been deprecated since iOS 16; tint is the modern replacement
        .tint(colorScheme == .dark ? CblTheme.light : CblTheme.red)
    }
}
