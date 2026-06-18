// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import SwiftData

// Local-first mirror of the `channels` table (server-side schema documented in
// Apps/Unit0x04/README.md, next to the existing global_message_queue SQL) —
// same client-generated-id / pending-then-synced pattern as LocalMessage, one
// table up. See MessagesViewModel.findOrCreateGlobalChannel/syncPendingChannels
// for how a row here gets created and pushed.
//
// ── Why a second table instead of a `channelName: String` on LocalMessage ───
//
// Because that IS the exercise: a channel is its own entity that many messages
// point AT, not a string copy-pasted onto every row. Two tables, one
// relationship:
//
//   LocalChannel.messages   — to-many   (a channel has many messages)
//   LocalMessage.channel    — to-one    (a message belongs to zero or one channel)
//
// SwiftData models that as ordinary Swift properties holding model instances —
// not as an integer foreign key you read/write by hand. The @Relationship
// macro below is only needed on ONE side, to say which two properties are the
// two ends of the same relationship (`inverse:`) and what happens to the
// "many" side when the "one" side is deleted (`deleteRule:`). Once that's
// declared, setting `message.channel = someChannel` automatically makes
// `someChannel.messages` contain that message too — both directions update
// from one assignment, the way Core Data's inverse relationships always did.
//
// deleteRule: .nullify (spelled out below even though it's the default) means
// deleting a LocalChannel detaches its messages rather than deleting them —
// moot here since there's deliberately no channel-management UI ("scan for
// 'global', create it if missing" is the entire feature), but it's the
// detail you'd reach for first if a real delete-a-channel flow ever showed up.
//
// @Attribute(.unique) on `name` is a local backstop, not the primary
// mechanism: findOrCreateGlobalChannel() always fetches-by-name FIRST and only
// creates a new row on a miss, so this constraint should normally never fire.
// It exists so a bug in that fetch-then-create logic fails loudly (a thrown
// save error) instead of quietly leaving two local "global" rows behind.
//
// syncStatus reuses MessageSyncStatus from LocalMessage.swift rather than a
// near-identical enum — "written locally, not yet confirmed by the server" /
// "server has this exact row" means the same thing for a channel as a message.

@Model
final class LocalChannel {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var name: String
    var createdAt: Date
    var syncStatusRaw: String

    @Relationship(deleteRule: .nullify, inverse: \LocalMessage.channel)
    var messages: [LocalMessage] = []

    var syncStatus: MessageSyncStatus {
        get { MessageSyncStatus(rawValue: syncStatusRaw) ?? .pending }
        set { syncStatusRaw = newValue.rawValue }
    }

    init(id: UUID, name: String, createdAt: Date, syncStatus: MessageSyncStatus) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.syncStatusRaw = syncStatus.rawValue
    }
}
