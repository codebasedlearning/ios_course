// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

/*
 We see a 'property wrapper' (@State). It wraps a stored property and adds behavior to it — in this case, telling SwiftUI: “This property is part of the view’s state, and if it changes, re-render the view.”
 
 When we add a '$' in front of a wrapped property (like @State), we’re accessing its projected value, i.e. the wrapper itself — not just the value inside. Here, $selectedTab is a 'binding' and TabView can read and write to 'selectedTab'. If we leave out the $, it is only a copy of the value, not the binding, so changes won’t go back. Adding '$' provides call-by-reference semantics.
 */

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlayScreen(selection: $selectedTab).tabItem {
                Label("Play", systemImage: "1.circle")
            }.tag(0)
            SettingsScreen(selection: $selectedTab).tabItem {
                Label("Settings", systemImage: "2.circle")
            }.tag(1)
        }
        .tint(.mint)
        .onAppear { selectedTab = 0 }
    }
}
