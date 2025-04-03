// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0 // screen no 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ChartScreen().tabItem {
                Label("Charts", systemImage: "1.circle")
            }.tag(0) // do not forget tag()
            BallsScreen().tabItem {
                Label("Balls", systemImage: "2.circle")
            }.tag(1)
            SpritesScreen().tabItem {
                Label("Boxes", systemImage: "3.circle")
            }.tag(2)
            MazeScreen().tabItem {
                Label("Maze", systemImage: "4.circle")
            }.tag(3)
            //ARScreen().tabItem {
            //    Label("AR", systemImage: "4.circle")
            //}.tag(3)
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
