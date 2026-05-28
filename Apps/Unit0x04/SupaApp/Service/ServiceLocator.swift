// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

class ServiceLocator {
    // Swift initialises 'static let' exactly once, lazily on first access, and
    // thread-safely (the runtime uses a dispatch_once-style lock under the hood).
    // That makes it safe to touch ServiceLocator.shared from any thread.
    static let shared = ServiceLocator()

    // Changed from 'lazy var' to 'let': both services are now initialised as part
    // of ServiceLocator.init() rather than on first individual access.
    //
    // Why this matters: Swift's 'lazy var' in a class is NOT thread-safe — two
    // threads racing to first-access the same lazy var can initialise it twice or
    // corrupt state.  Storing them as plain 'let's sidesteps that entirely: they
    // are initialised once, inside the thread-safe static-let initialisation of
    // 'shared', and never touched again.
    let networkMonitor = NetworkMonitor()
    let databaseConnector = DatabaseConnector()
}
