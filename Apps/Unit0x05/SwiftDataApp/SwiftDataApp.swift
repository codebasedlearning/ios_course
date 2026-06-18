// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

/*
 .modelContainer(for:) is the SwiftData equivalent of Core Data’s NSPersistentContainer
 - ModelContainer = the store (schema + persistent storage); one per app, typically
 - ModelContext = a scratchpad / unit of work attached to a container; the main one
    comes for free via the environment; you make extra ones for background actors
 - a single context can fetch, insert, update, and delete any model type that's part of that schema
 
 Under the hood, it:
 - Analyzes your @Model types (e.g., Book, Author) and builds a schema.
 - Creates a persistent store, backed by SQLite (by default).
 - SwiftData is a new API surface, but underneath it sits on top of
    Core Data's persistence stack, which uses SQLite as the default store
 - Injects the container into the environment, so:
    @Environment(\.modelContext) works
    @Query can fetch models
    modelContext.insert(), delete(), etc., work seamlessly
 - modelContainer also wires up autosave behavior and ties the container's
    lifetime to the SwiftUI scene/view
 - for background work (imports, batch deletes), you should not use
    \.modelContext; instead grab the container via \.modelContext.container;
    Contexts are not thread-safe; the container is
 - a ModelContext has an autosaveEnabled flag (default true for the
    environment-injected mainContext you get via .modelContainer); when it's
    on, SwiftData calls save() for you at "opportune moments"
 -
 */

import SwiftUI

@main
struct SwiftDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Author.self, Book.self])
    }
}
