// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

@main
struct SupaApp: App {
    @State private var networkViewModel = NetworkViewModel()
    @State private var databaseConnectorViewModel = DatabaseConnectorViewModel()
    @State private var messagesViewModel = MessagesViewModel()

    // Note on ServiceLocator design — lazy var vs. let:
    // ServiceLocator's services (networkMonitor, databaseConnector) are 'let'
    // properties, not 'lazy var'. The distinction matters for thread safety:
    // Swift's 'lazy var' in a class has NO lock — two threads racing to first-
    // access the same lazy property can initialise it twice or corrupt state.
    // Plain 'let' properties are initialised once inside ServiceLocator.init(),
    // which itself runs inside the 'static let shared' initialisation. Swift
    // guarantees static-let initialisation is thread-safe (dispatch_once
    // semantics), so every caller gets the same, fully-constructed instance.

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(networkViewModel)
                .environment(databaseConnectorViewModel)
                .environment(messagesViewModel)
        }
    }
}
