// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            SensorsScreen().tabItem {
                Label("Sensors", systemImage: "1.circle")
            }.tag(0)
            AirDropScreen().tabItem {
                Label("AirDrop", systemImage: "2.circle")
            }.tag(1)
            BTScreen().tabItem {
                Label("BT", systemImage: "3.circle")
            }.tag(2)
            HapticScreen().tabItem {
                Label("Haptic", systemImage: "4.circle")
            }.tag(3)
            ScannerScreen().tabItem {
                Label("Scanner", systemImage: "5.circle")
            }.tag(4)
            NFCScreen().tabItem {
                Label("NFC", systemImage: "6.circle")
            }.tag(5)
            SmartCardScreen().tabItem {
                Label("Smart Card", systemImage: "7.circle")
            }.tag(6)
        }
        .tint(colorScheme == .dark ? CblTheme.light : CblTheme.red)
        .onAppear { selectedTab = 0 }
    }
}

// tbd: maybe this should go to CblUI?

struct ScreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(CblTheme.dark)
            .foregroundColor(CblTheme.light)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(CblTheme.light, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)            
    }
}
