// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import SwiftData

// Local-first persistence for the messages feature (see MessagesViewModel).
//
// Every message — composed locally or pulled from the server — lives here as a
// LocalMessage row. The `id` is always the SAME UUID on both sides: the client
// generates it at compose time and sends it explicitly in the Supabase insert
// (see GlobalMessageQueueInsertData), instead of letting Postgres assign one.
// That single decision is what makes the rest of the sync logic simple:
//   - the optimistic local row IS the eventual server row, same primary key
//   - a server fetch can be merged in by "upsert on id" instead of fuzzy matching
//   - a retried insert after a dropped ack collides on the same id (Postgres
//     unique-violation) instead of creating a duplicate — which MessagesViewModel
//     treats as "oh good, already synced" rather than an error
//
// syncStatus distinguishes "written locally, not yet confirmed by the server"
// (.pending) from "server has this exact row" (.synced). It IS the outbox —
// there's no separate pending-mutations table, because for a single insert-only
// chat table the row itself already carries everything an outbox entry would.
//
// What does NOT happen: a row never gets deleted just because it reached
// .synced. This table is a full local mirror of the channel — everyone's
// messages, not just rows we created — not a transient outbox that's emptied
// once the network catches up. That's a deliberate choice, not an oversight:
// the only thing refreshFromLocalStore() does is read the WHOLE table and hand
// it to the UI, online or offline, so message history is visible with zero
// network — that's the entire point of "offline-first" rather than merely
// "offline-tolerant". The trade-off, worth knowing rather than discovering the
// hard way: this table only ever grows. A real production chat app would add a
// retention window or row cap with eviction; a course example gets to skip
// that and let the SQLite file grow, undisturbed, into eternity.
// ── SwiftData, briefly ───────────────────────────────────────────────────────
//
// SwiftData (WWDC23) is Apple's declarative persistence framework — Core Data's
// spiritual successor, same SQLite engine underneath, but the object graph IS
// the schema instead of living in a separate .xcdatamodeld file you edit in a
// GUI. Five pieces show up across this file and MessagesViewModel:
//
//   @Model           Macro-generates the boilerplate (PersistentModel
//                     conformance, change tracking, schema reflection) from a
//                     plain class. LocalMessage below looks like "just a class"
//                     to you; the compiler turns it into a managed, persisted
//                     entity.
//   ModelContainer    The database itself — one SQLite file plus the schema
//                     derived from your @Model types. One per app (see
//                     ServiceLocator), same idea as Core Data's
//                     NSPersistentContainer.
//   ModelContext      A staging area / unit-of-work bound to ONE container.
//                     Inserts, deletes, and property mutations are tracked here
//                     and only hit disk on .save(). It is NOT thread-safe to
//                     share between isolation domains — exactly why
//                     MessagesViewModel owns its own context and is @MainActor.
//   FetchDescriptor   A type-safe query: "give me LocalMessage rows matching X,
//                     sorted by Y", built against real KeyPaths — a typo'd
//                     property name is a compile error, not a query that
//                     silently returns nothing at runtime.
//   #Predicate        A macro that compiles an ordinary-looking Swift closure
//                     (e.g. `{ $0.syncStatusRaw == pendingRaw }`) down to
//                     something SwiftData can run as SQL. It is NOT filtering
//                     an array already in memory — the predicate executes
//                     inside the database.
//
// And @Attribute(.unique) on `id` below is a real uniqueness constraint at the
// storage layer, not just a naming convention — it's what makes "retry an
// insert, collide on id, treat the collision as success" in
// MessagesViewModel.syncPendingMessages() actually safe rather than hopeful.
//
// Core Data with the ORM ceremony is removed.
// SwiftData writes the SQL — you just still owe it a coherent schema, same as
// any database that's ever existed.
// ────────────────────────────────────────────────────────────────────────────
//
// ── `channel`: the relationship side of this story ──────────────────────────
//
// See LocalChannel.swift for the full writeup. The short version: `channel`
// below is the to-one end of a to-many/to-one relationship — many LocalMessage
// rows, one LocalChannel. It's declared as a perfectly ordinary optional
// stored property; the @Relationship macro (with its `inverse:`) lives on the
// OTHER side, in LocalChannel.messages, and that single declaration is enough
// for SwiftData to keep both directions in sync whenever either one is set.
//
// Optional, not required: rows already in the local store from before this
// feature existed have no channel at all, and SwiftData's lightweight
// migration handles "I added an optional property" for free — no migration
// plan needed, unlike a required property which would need a default or a
// proper VersionedSchema.

enum MessageSyncStatus: String, Codable {
    case pending
    case synced
}

@Model
final class LocalMessage {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var email: String?
    var command: String?
    var payload: String?
    var userId: UUID?          // only set for rows WE created; nil for rows merged in from the server
    var syncStatusRaw: String
    var channel: LocalChannel?  // to-one; inverse declared on LocalChannel.messages

    var syncStatus: MessageSyncStatus {
        get { MessageSyncStatus(rawValue: syncStatusRaw) ?? .pending }
        set { syncStatusRaw = newValue.rawValue }
    }

    init(id: UUID, createdAt: Date, email: String?, command: String?, payload: String?, userId: UUID?, syncStatus: MessageSyncStatus, channel: LocalChannel? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.email = email
        self.command = command
        self.payload = payload
        self.userId = userId
        self.syncStatusRaw = syncStatus.rawValue
        self.channel = channel
    }
}
