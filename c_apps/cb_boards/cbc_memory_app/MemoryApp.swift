// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

@main
struct MemoryApp: App {
    @State private var memoryViewModel = MemoryViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(memoryViewModel)
        }
    }
}
