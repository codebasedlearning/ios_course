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
            //if connector.isAuthenticated {
            // always visible for offline-mode
            MessagesScreen()
                .tabItem { Label("Messages", systemImage: "2.circle") }
                .tag(1)
            //}
        }
        .tint(colorScheme == .dark ? CblTheme.light : CblTheme.red)
        // NOT connector.isAuthenticated: that's the live, SDK-driven flag that's
        // documented to blip false while offline (see DatabaseConnector's long
        // comment on lastKnownUserId). Keying the tab switch on it meant an
        // offline blip could yank you back to Login mid-compose on the Messages
        // tab. hasKnownIdentity only changes on a real sign-in or an explicit
        // signOut() call, so a flaky network can't move it.
        .onChange(of: connector.hasKnownIdentity) { _, hasIdentity in
            selectedTab = hasIdentity ? 1 : 0
        }
    }
}
