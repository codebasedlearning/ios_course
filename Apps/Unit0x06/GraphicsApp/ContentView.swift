// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ChartScreen().tabItem {
                Label("Charts", systemImage: "1.circle")
            }.tag(0)
            AnimationScreen().tabItem {
                Label("Animation", systemImage: "2.circle")
            }.tag(1)
            SpritesScreen().tabItem {
                Label("Sprites", systemImage: "3.circle")
            }.tag(2)
            MazeScreen().tabItem {
                Label("Maze", systemImage: "4.circle")
            }.tag(3)
            ARScreen().tabItem {
                Label("AR", systemImage: "5.circle")
            }.tag(4)
        }
        .accentColor(colorScheme == .dark ? CblTheme.light : CblTheme.red)
        .onAppear { selectedTab = 0 }
    }
}
