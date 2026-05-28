// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import Supabase

import CblUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(DatabaseConnectorViewModel.self) var connector
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            LoginScreen()
                .tabItem { Label("Login", systemImage: "1.circle") }
                .tag(0)
            if connector.isAuthenticated {
                MessagesScreen()
                    .tabItem { Label("Messages", systemImage: "2.circle") }
                    .tag(1)
            }
        }
        .tint(colorScheme == .dark ? CblTheme.light : CblTheme.red)
        .onChange(of: connector.isAuthenticated) { _, isAuthenticated in
            selectedTab = isAuthenticated ? 1 : 0
        }
    }
}
