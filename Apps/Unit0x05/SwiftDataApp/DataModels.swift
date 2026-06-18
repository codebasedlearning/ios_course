// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import SwiftData

/*
 When you add @Model to a class, it generates:
 - Schema metadata (what fields exist, types, relationships)
 - Persistence glue (automatic database syncing)
 - Conformance to required protocols (like Identifiable)
 - Support for SwiftUI’s @Query and $book bindings
 
 Requirements
 - Only classes — not structs or enums.
 - Must conform to reference semantics (i.e., pass by reference).
 - Properties must be Swift-supported types: String, Date, Int, relationships, etc.
 
 Features
 - Schema generation
 - Persistence
 - SwiftUI-friendly bindings (@Query, $book)
 - Replaces NSManagedObject
 - Integrates with .modelContainer

 SwiftData (always) implicitly gives your model a
    var id: PersistentIdentifier
 - It’s unique per object, like a UUID, store-specific, not stable across
    stores and good for in-memory references
 - It conforms to Identifiable, so you can use it in ForEach, List, etc.
 - You don’t need to declare it manually unless you want control over the ID format.
 - You can't opt out, and you can't swap it for UUID. It's SwiftData's
    internal handle to the row in the store
 - It is not Codable/Hashable-portable in a meaningful way — don't persist it
    outside SwiftData or send it over the network
 - You can also have a UUID, stable across devices, useful for syncing with
    a server, exporting, sharing in URLs, matching against remote records (databases)
 
 Relations
 - These are a bidirectional syncs — you can safely modify either side, and SwiftData keeps them in sync.
 */

@Model
class Author {
    // optional
    // @Attribute(.unique) var id: UUID
    
    var name: String
    
    // define a 1-to-many relationship where:
    // - One Author has many Books
    // - Each Book references one Author
    // - When the Author is deleted, all associated Books are also deleted
    //
    // SwiftData also supports many-to-many relationships
    @Relationship(deleteRule: .cascade) var books: [Book] = []
    
    // If matching by type is ambiguous, you must disambiguate
    //  @Relationship(deleteRule: .cascade, inverse: \Book.author) var books: [Book] = []
    
    // not stored, will not trigger persistence updates or participate in save/load cycles
    @Transient var temporaryNote: String = ""

    init(name: String) {
        self.name = name
    }
}

@Model
class Book {
    var title: String
    var timestamp: Date
    // Inverse reference, SwiftData detects them as inverses by type matching
    // and keeps them in sync automatically
    var author: Author?
    
    init(title: String, author: Author, timestamp: Date = .now) {
        self.title = title
        self.timestamp = timestamp
        self.author = author
    }
}

/*
 What is @something in Swift?
 
 
 Two different things share that prefix.

 1. Attributes (the older, simpler thing)
 The @ syntax has existed since Swift 1 as an attribute — a marker the compiler
 recognizes and applies special handling to. Examples: @available, @objc, @MainActor,
 @discardableResult, @escaping, @Sendable. These are baked into the compiler;
 you can't define your own.

 2. Macros (Swift 5.9+, the new thing)
 A macro is user-extensible compile-time code generation. You write Swift code
 that takes the syntax tree of the annotated declaration as input and emits new syntax
 that gets compiled in alongside it. The compiler hands the input AST to your macro
 implementation, you return modified/added code, and the compiler proceeds as
 if you'd typed it yourself.

 There are two macro flavors syntactically:
 - Attached macros: @Model, @Observable, @Query, @Attribute(.unique) — they
    decorate a declaration.
 - Freestanding macros: #Predicate { ... }, #warning(...), #URL(...) — they
    appear as expressions.
 */
