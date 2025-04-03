/// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0 // screen no 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GesturesScreen().tabItem {
                Label("Gestures", systemImage: "1.circle")
            }.tag(0) // do not forget tag()
            MapScreen().tabItem {
                Label("Map", systemImage: "2.circle")
            }.tag(1)
            SensorsScreen().tabItem {
                Label("Sensors", systemImage: "3.circle")
            }.tag(2)
            PhotoScreen().tabItem {
                Label("Photo", systemImage: "4.circle")
            }.tag(3)
        }
        .onAppear { selectedTab = loadSelectedTab() }
        .onChange(of: selectedTab) { oldState, newState in saveSelectedTab(newState) }
    }
    
    private static let selectedTabKey = "lastSelectedTab"

    private func loadSelectedTab() -> Int {
        return UserDefaults.standard.integer(forKey: ContentView.selectedTabKey)
    }
    
    private func saveSelectedTab(_ newState: Int) {
        UserDefaults.standard.set(newState, forKey: ContentView.selectedTabKey)
    }
}
