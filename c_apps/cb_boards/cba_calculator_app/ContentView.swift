// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CalculatorScreen().tabItem {
                Label("Calculator", systemImage: "1.circle")
            }.tag(0)
        }
        .onAppear { selectedTab = 0 }
    }
}
