// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import SwiftData

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

    // Backing store for the offline-first message outbox/cache (LocalMessage,
    // see MessagesViewModel). One ModelContainer for the whole app, same
    // singleton-via-'let' reasoning as the two services above; each consumer
    // creates its own ModelContext from it rather than sharing one context.
    //
    // LocalChannel.self is listed alongside LocalMessage.self because ONE
    // ModelContainer holds the ENTIRE schema, not one table — every @Model
    // type that should get a table in the underlying SQLite file has to be
    // named here. Forget this and LocalChannel just silently has no storage:
    // not a compile error, a runtime one the first time you fetch/insert it.
    // SwiftData also walks the @Relationship graph from the types you list,
    // so technically just `LocalMessage.self` would have pulled LocalChannel
    // in automatically too — but listing both is clearer and doesn't rely on
    // remembering that inference rule.
    let modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: LocalMessage.self, LocalChannel.self)
        } catch {
            fatalError("[ServiceLocator] could not create ModelContainer: \(error)")
        }
    }()
}
