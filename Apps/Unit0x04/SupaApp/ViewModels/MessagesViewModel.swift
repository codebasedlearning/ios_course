// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import Supabase
import Combine
import SwiftData

fileprivate let logger = PredefinedLogger.dataLogger

struct ReadAllMessagesViewData: Decodable, Hashable, Identifiable {
    let id: UUID
    let createdAt: Date     // Supabase SDK decodes snake_case → camelCase automatically
    let email: String?
    let message: [String: String]?
    let channelId: UUID?     // nil for old rows predating this feature
    let channelName: String? // denormalised here by the read_all_messages VIEW (a join),
                              // purely so the UI can print it without a second round-trip —
                              // the local mirror gets the real relationship instead, see
                              // refreshFromLocalStore()/resolveChannel() below.

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case email
        case message
        case channelId = "channel_id"
        case channelName = "channel_name"
    }
}

struct GlobalMessageQueueInsertData: Encodable, Hashable {
    let id: UUID             // client-generated (see LocalMessage) — lets the optimistic local
                              // row and the eventual server row share one primary key, instead
                              // of letting Postgres assign one we'd have to reconcile later.
                              // Requires the table's id column to accept a client-supplied value
                              // on insert (plain DEFAULT gen_random_uuid(), not GENERATED ALWAYS).
    let userId: UUID        // Supabase SDK encodes camelCase → snake_case automatically
    let message: [String: String]
    let channelId: UUID?    // FK into public.channels; insertMessage() always resolves one
                              // via findOrCreateGlobalChannel() before getting here.

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case message
        case channelId = "channel_id"
    }
}

// Mirrors GlobalMessageQueueInsertData's role, one table over: client-generated
// id, pushed by syncPendingChannels(). See that function's comment for the
// name-collision case this has to handle, which LocalMessage's sync never does.
struct GlobalChannelInsertData: Encodable, Hashable {
    let id: UUID
    let name: String
}

// What we read back when checking "does a channel with this name already exist
// on the server" — deliberately narrower than the full channels row; channel
// reconciliation only ever needs these two fields.
struct ReadChannelData: Decodable, Hashable {
    let id: UUID
    let name: String
}

// ── Offline-first design ─────────────────────────────────────────────────────
//
// Previously this class deliberately stayed off the main actor (it only ever
// spawned its own short-lived Tasks). That changes here: it now owns a SwiftData
// ModelContext, and a ModelContext is not safe to touch from more than one
// isolation domain at once. @MainActor gives it exactly one domain — the same
// one SwiftUI already calls insertMessage/fetchMessages from — so every access
// is serialised for free, no extra locking needed.
//
// (If @Model / ModelContext / FetchDescriptor / #Predicate below are new
// vocabulary, see the "SwiftData, briefly" block at the top of LocalMessage.swift
// — this file just puts those pieces to work, it doesn't re-explain them.)
//
// Flow for "compose offline, sync on reconnect":
//   1. insertMessage writes a LocalMessage row immediately (.pending) and the
//      UI refreshes from the local store — instant, online or not.
//   2. It also tries to push right away (best-effort; harmless no-op if offline).
//   3. NetworkMonitor is watched here too (its own makeEventStream() call,
//      see below): on the false→true edge, syncPendingMessages() drains every
//      still-.pending row in order.
//   4. fetchMessages() (driven by Realtime via messagesChangedStream, or a
//      manual pull) no longer replaces `messages` outright — it merges server
//      rows into the local store by id, which is what reconciles "my own
//      optimistic echo" with "the server's confirmation of that same row".
// ─────────────────────────────────────────────────────────────────────────────

@Observable
@MainActor
class MessagesViewModel {
    var messages: [ReadAllMessagesViewData] = []

    // Every failure inside insertMessage used to be logger-only — from the UI's
    // point of view "no known identity yet" and "modelContext.save() threw" were
    // both indistinguishable from "worked fine": tap Send, list doesn't change,
    // silence. That's not a hypothesis, it's a structural fact about the old
    // code: every early-return path only called logger.error/.notice. Surfacing
    // it here so MessagesScreen can show *something* instead of nothing.
    var lastError: String? = nil

    // ── OLD Combine version (kept for comparison, not deleted) ──────────────
    //
    // private var cancellables = Set<AnyCancellable>()
    //
    // init() {
    //     // Subscribe to realtime table-change signals from DatabaseConnector.
    //     // Debounce so a burst of rapid inserts only triggers one fetch.
    //     ServiceLocator.shared.databaseConnector.messagesChangedPublisher
    //         .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    //         .sink { [weak self] in
    //             self?.fetchMessages()
    //         }
    //         .store(in: &cancellables)
    // }
    // ──────────────────────────────────────────────────────────────────────

    // NEW: AsyncStream replaces PassthroughSubject — but AsyncSequence has no
    // .debounce operator in the standard library, so it's reimplemented by hand:
    // each incoming signal cancels any pending fetch and schedules a fresh one
    // after the same 300ms; if another signal arrives first, Task.isCancelled
    // short-circuits the stale one before it can call fetchMessages().
    //
    // nonisolated(unsafe) on all three: same reason as NetworkViewModel/
    // DatabaseConnectorViewModel — deinit can't be actor-isolated, so a
    // @MainActor-isolated property can't be referenced inside it without this.
    nonisolated(unsafe) private var listenTask: Task<Void, Never>?
    nonisolated(unsafe) private var debounceTask: Task<Void, Never>?
    nonisolated(unsafe) private var networkListenTask: Task<Void, Never>?

    private let modelContext: ModelContext

    init() {
        modelContext = ModelContext(ServiceLocator.shared.modelContainer)
        refreshFromLocalStore() // show whatever's cached locally before any network call lands

        listenTask = Task { [weak self] in
            for await _ in ServiceLocator.shared.databaseConnector.messagesChangedStream {
                guard let self else { return }
                self.debounceTask?.cancel()
                self.debounceTask = Task { [weak self] in
                    try? await Task.sleep(for: .milliseconds(300))
                    guard let self, !Task.isCancelled else { return }
                    // await directly rather than self.fetchMessages() — we're
                    // already inside debounceTask, no need to spawn a second,
                    // untracked child Task just to call an async function.
                    await self.fetchAndMergeMessages()
                }
            }
        }

        // Own, independent subscription via makeEventStream() — deliberately
        // NOT the same shared stream instance NetworkViewModel reads from.
        // AsyncStream is single-consumer: two `for await` loops fighting over
        // ONE AsyncStream steal elements from each other instead of each
        // seeing every value (that mistake is exactly what made connectivity
        // look wrong at launch and after toggling the network — see the long
        // writeup in NetworkMonitor.swift). makeEventStream() hands back a
        // fresh stream, fed by the same NWPathMonitor, seeded with the
        // current status, so this loop and NetworkViewModel's no longer
        // compete for the same values.
        //
        // On the false→true edge, drain whatever queued up locally while we
        // were offline.
        networkListenTask = Task { [weak self] in
            var wasConnected = false
            for await isConnected in ServiceLocator.shared.networkMonitor.makeEventStream() {
                guard let self else { return }
                if isConnected, !wasConnected {
                    logger.notice("[MessagesViewModel] back online — draining outbox")
                    await self.syncPendingChannels()  // channels first — messages FK-reference them
                    await self.syncPendingMessages()
                }
                wasConnected = isConnected
            }
        }
    }

    deinit {
        listenTask?.cancel()
        debounceTask?.cancel()
        networkListenTask?.cancel()
    }

    func insertMessage(message: String) {
        let connector = ServiceLocator.shared.databaseConnector

        // Deliberately NOT connector.isAuthenticated here. This write only ever
        // touches modelContext (local SwiftData, zero network), so it only needs
        // a stable identity to label the row with — not a live, network-derived
        // flag that the Supabase SDK is known to occasionally get wrong, exactly
        // while offline (see DatabaseConnector.lastKnownUserId for the why and
        // the GitHub issues backing it up). isAuthenticated still gates the
        // actual network push, two steps down, in syncPendingMessages().
        guard let userId = connector.lastKnownUserId else {
            logger.notice("[MessagesViewModel] insert: no known identity, dropping")
            lastError = "Can't send: no signed-in identity yet. Sign in once while online, then offline composing works."
            return
        }

        // 0) Resolve (or create) the "global" channel locally first — this is
        //    the to-one side of the relationship getting populated. Still pure
        //    local SwiftData, no network, same as the message write below.
        let channel = findOrCreateGlobalChannel()

        // 1) Local-first write — succeeds instantly, online or offline.
        let local = LocalMessage(
            id: UUID(), createdAt: Date(),
            email: connector.userProfile?.email ?? connector.lastKnownEmail,
            command: "message", payload: message, userId: userId, syncStatus: .pending,
            channel: channel
        )
        modelContext.insert(local)
        do {
            // One save persists BOTH the (new-or-looked-up) LocalChannel and the
            // new LocalMessage, plus the relationship between them — SwiftData
            // walks the object graph from `local`, finds `local.channel` is
            // dirty too, and saves it in the same transaction. Related rows
            // across tables don't need separate save() calls.
            try modelContext.save()
        } catch {
            logger.error("[MessagesViewModel] local insert error:\(error)")
            lastError = "Local save failed: \(error.localizedDescription)"
            return
        }
        lastError = nil
        refreshFromLocalStore()
        logger.notice("[MessagesViewModel] queued message locally:\(message)")

        // 2) Best-effort push right now. If we're offline this just fails and
        //    the rows stay .pending — networkListenTask retries on reconnect.
        //    Channel before message, deliberately: the message's channel_id is
        //    a real foreign key into public.channels, so pushing the message
        //    first would just bounce off a FK violation if the channel hasn't
        //    landed server-side yet.
        Task {
            await syncPendingChannels()
            await syncPendingMessages()
        }
    }

    // Drains every .pending LocalMessage row, oldest first, pushing each to
    // Supabase with the SAME id it was created with locally.
    func syncPendingMessages() async {
        let connector = ServiceLocator.shared.databaseConnector
        guard connector.isAuthenticated else { return }
        let supabase = connector.supabaseClient

        let pendingRaw = MessageSyncStatus.pending.rawValue
        let descriptor = FetchDescriptor<LocalMessage>(
            predicate: #Predicate<LocalMessage> { $0.syncStatusRaw == pendingRaw },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        guard let pending = try? modelContext.fetch(descriptor), !pending.isEmpty else { return }
        logger.notice("[MessagesViewModel] draining \(pending.count) pending message(s)")

        for row in pending {
            guard let userId = row.userId else { continue } // only rows we created carry this

            // channel_id is a real FK — this message can't go to the server until
            // its channel has a server-confirmed id. If syncPendingChannels()
            // hasn't reached (or couldn't reach) this row's channel yet, leave the
            // message .pending; it's retried on the next drain.
            if let channel = row.channel, channel.syncStatus != .synced {
                logger.notice("[MessagesViewModel] \(row.id) waiting on its channel to sync first")
                continue
            }

            let insertData = GlobalMessageQueueInsertData(
                id: row.id, userId: userId,
                message: ["command": row.command ?? "message", "payload": row.payload ?? ""],
                channelId: row.channel?.id
            )
            do {
                try await supabase.from("global_message_queue").insert(insertData).execute()
                row.syncStatus = .synced
            } catch let error as PostgrestError where error.code == "23505" {
                // unique-violation on the client-generated id: a previous attempt
                // already reached the server, we just never saw the ack. Same id,
                // so this IS that row — count it as synced, not a failure.
                logger.notice("[MessagesViewModel] \(row.id) already on server, marking synced")
                row.syncStatus = .synced
            } catch {
                logger.error("[MessagesViewModel] sync error for \(row.id):\(error)")
                break // stop draining to preserve order; the rest retry next time
            }
        }

        try? modelContext.save()
        refreshFromLocalStore()
    }

    // The one hardcoded channel name this whole feature deliberately revolves
    // around. Per spec there's no channel-management UI/CRUD at all — this is
    // purely a "look at relationships and multiple tables working together"
    // exercise, not a real multi-channel chat feature.
    private let globalChannelName = "global"

    // Local-only, synchronous, zero network: returns the "global" LocalChannel
    // if one already exists, otherwise creates a new .pending one. Called from
    // insertMessage() right before building the LocalMessage row, so every new
    // message always has SOME channel for its `channel` relationship to point at.
    private func findOrCreateGlobalChannel() -> LocalChannel {
        let name = globalChannelName
        let descriptor = FetchDescriptor<LocalChannel>(predicate: #Predicate<LocalChannel> { $0.name == name })
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        logger.notice("[MessagesViewModel] no local '\(name)' channel yet — creating one")
        let channel = LocalChannel(id: UUID(), name: name, createdAt: Date(), syncStatus: .pending)
        modelContext.insert(channel)
        return channel
    }

    // Drains every .pending LocalChannel row, pushing each to Supabase with the
    // SAME id it was created with locally — same idempotent-retry idea as
    // syncPendingMessages(), but the uniqueness collision guarded against here
    // is a different SHAPE of problem. There, every retry is the same client
    // resending the same id. Here, TWO DIFFERENT offline clients can each
    // invent their own "global" LocalChannel with two different random UUIDs
    // while both are offline — only one of those names can win the server's
    // `unique` constraint on `name`.
    //
    // This is the one spot in the whole feature where the relationship really
    // earns its keep. When our LocalChannel loses that race, we do NOT go
    // hunt down every LocalMessage that points at it and rewrite a foreign-key
    // column by hand. We overwrite `row.id` on the ONE LocalChannel object —
    // every LocalMessage whose `.channel` already points at THAT SAME object
    // sees the corrected id "for free", because it never held a copy of the
    // id, it held the object. That's the whole pitch for "messages point at a
    // channel" over "messages carry a channelName string".
    func syncPendingChannels() async {
        let connector = ServiceLocator.shared.databaseConnector
        guard connector.isAuthenticated else { return }
        let supabase = connector.supabaseClient

        let pendingRaw = MessageSyncStatus.pending.rawValue
        let descriptor = FetchDescriptor<LocalChannel>(
            predicate: #Predicate<LocalChannel> { $0.syncStatusRaw == pendingRaw }
        )
        guard let pending = try? modelContext.fetch(descriptor), !pending.isEmpty else { return }
        logger.notice("[MessagesViewModel] draining \(pending.count) pending channel(s)")

        for row in pending {
            let insertData = GlobalChannelInsertData(id: row.id, name: row.name)
            do {
                try await supabase.from("channels").insert(insertData).execute()
                row.syncStatus = .synced
            } catch let error as PostgrestError where error.code == "23505" {
                // Name collision, NOT an id collision (contrast with
                // syncPendingMessages()'s 23505 case) — see the long comment above.
                if let serverChannel = try? await fetchChannel(named: row.name, supabase: supabase) {
                    logger.notice("[MessagesViewModel] channel '\(row.name)' already exists on server as \(serverChannel.id) — adopting its id")
                    row.id = serverChannel.id
                    row.syncStatus = .synced
                } else {
                    logger.error("[MessagesViewModel] channel '\(row.name)' collided on server but re-fetch failed")
                    break
                }
            } catch {
                logger.error("[MessagesViewModel] channel sync error for \(row.id):\(error)")
                break // stop draining to preserve order; the rest retry next time
            }
        }

        try? modelContext.save()
    }

    private func fetchChannel(named name: String, supabase: SupabaseClient) async throws -> ReadChannelData? {
        let rows: [ReadChannelData] = try await supabase
            .from("channels")
            .select("id, name")
            .eq("name", value: name)
            .execute()
            .value
        return rows.first
    }

    // Fire-and-forget wrapper for call sites that aren't already in an async
    // context (the .onAppear in MessagesScreen, for one). Everything that IS
    // already async — syncNow(), the Realtime debounce above — awaits
    // fetchAndMergeMessages() directly instead, no point spawning a Task
    // inside a Task.
    func fetchMessages() {
        Task {
            await fetchAndMergeMessages()
        }
    }

    private func fetchAndMergeMessages() async {
        let supabase = ServiceLocator.shared.databaseConnector.supabaseClient
        do {
            logger.notice("[MessagesViewModel] fetch messages")
            let serverRows: [ReadAllMessagesViewData] = try await supabase
                .from("read_all_messages")
                .select("id, created_at, email, message, channel_id, channel_name")
                .execute()
                .value
            merge(serverRows: serverRows)
            logger.notice("[MessagesViewModel] fetch messages worked")
        } catch {
            logger.error("[MessagesViewModel] fetch error:\(error)")  // was "insert error" — copy-paste bug
        }
    }

    // ── Manual "Sync" button entry point ─────────────────────────────────────
    //
    // Everything in here ALREADY happens automatically, just scattered across
    // different triggers: syncPendingChannels()/syncPendingMessages() fire on
    // the offline→online edge and right after composing; fetchAndMergeMessages()
    // fires off Realtime's messagesChangedStream. syncNow() exists so a person
    // (or a student poking at the UI) can force the whole pipeline to run RIGHT
    // NOW, in the right order, without waiting for one of those triggers — and
    // see local state, server state, and the relationship reconciliation all
    // settle in one visible step:
    //   1. push pending channels   (so messages have a synced FK target)
    //   2. push pending messages   (now safe — their channel_id exists server-side)
    //   3. pull + merge server rows (pick up anything pushed from elsewhere)
    //   4. prune local rows that claim .synced but the server no longer has
    //      (see pruneStaleSyncedRows() — this is the only thing NOT already
    //      wired to an automatic trigger; everyday operation rarely needs it,
    //      but it's cheap insurance and belongs in "do a full sync" either way)
    func syncNow() async {
        logger.notice("[MessagesViewModel] manual sync requested")
        await syncPendingChannels()
        await syncPendingMessages()
        await fetchAndMergeMessages()
        await pruneStaleSyncedRows()
    }

    // Upsert-by-id: a server row whose id matches a local one (because WE
    // generated that id, see LocalMessage) updates that row in place and marks
    // it .synced — that's how an optimistic echo and its server confirmation
    // become one row instead of two. A server row with no local match is
    // someone else's message (or one of ours from another device).
    private func merge(serverRows: [ReadAllMessagesViewData]) {
        for serverRow in serverRows {
            // Resolve the relationship FIRST: turn the view's flattened
            // (channel_id, channel_name) columns back into a real LocalChannel
            // object reference before touching the message row.
            let channel = resolveChannel(id: serverRow.channelId, name: serverRow.channelName)

            let targetId = serverRow.id
            let descriptor = FetchDescriptor<LocalMessage>(predicate: #Predicate<LocalMessage> { $0.id == targetId })
            if let existing = try? modelContext.fetch(descriptor).first {
                existing.createdAt = serverRow.createdAt
                existing.email = serverRow.email
                existing.command = serverRow.message?["command"]
                existing.payload = serverRow.message?["payload"]
                existing.syncStatus = .synced
                existing.channel = channel  // re-point at the (possibly just-resolved) LocalChannel object
            } else {
                let local = LocalMessage(
                    id: serverRow.id, createdAt: serverRow.createdAt, email: serverRow.email,
                    command: serverRow.message?["command"], payload: serverRow.message?["payload"],
                    userId: nil, syncStatus: .synced, channel: channel
                )
                modelContext.insert(local)
            }
        }
        try? modelContext.save()
        refreshFromLocalStore()
    }

    // Finds (or, on a miss, creates) the LocalChannel matching a server-confirmed
    // id/name pair from a fetched message row. Unlike findOrCreateGlobalChannel()
    // — which only ever deals with OUR OWN not-yet-synced "global" channel — this
    // is the read path: the server already settled this channel's real id and
    // name, so any new local row it creates here goes straight in as .synced,
    // no outbox round-trip needed.
    private func resolveChannel(id: UUID?, name: String?) -> LocalChannel? {
        guard let id, let name else { return nil }
        let descriptor = FetchDescriptor<LocalChannel>(predicate: #Predicate<LocalChannel> { $0.id == id })
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let channel = LocalChannel(id: id, name: name, createdAt: Date(), syncStatus: .synced)
        modelContext.insert(channel)
        return channel
    }

    private func refreshFromLocalStore() {
        let descriptor = FetchDescriptor<LocalMessage>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        guard let rows = try? modelContext.fetch(descriptor) else { return }
        messages = rows.map { row in
            ReadAllMessagesViewData(
                id: row.id,
                createdAt: row.createdAt,
                email: row.email,
                message: ["command": row.command ?? "", "payload": row.payload ?? ""],
                // Read straight off the relationship — row.channel is a real
                // SwiftData-managed object reference, not a column we kept in
                // sync by hand. It's the SAME LocalChannel object every other
                // message in this channel also points at.
                channelId: row.channel?.id,
                channelName: row.channel?.name
            )
        }
    }

    // ── Maintenance: pruning rows that THINK they're synced but aren't anymore ──
    //
    // Why this exists: syncStatus == .synced is a claim about the past ("the
    // server had this row, last time we checked"), not a live guarantee. If the
    // server-side table gets dropped and recreated — exactly what happens when
    // you apply the README's schema to a Supabase project that already had the
    // OLD global_message_queue/read_all_messages without channels — every
    // locally-cached .synced row is now describing a server row that no longer
    // exists. Nothing in the normal sync path notices that on its own; it only
    // ever pushes .pending rows, it never re-verifies .synced ones.
    //
    // This function closes that gap, on demand: fetch just the ids the server
    // currently has (one cheap select per table), and delete any LOCAL row
    // that's marked .synced but isn't in that set. .pending rows are left
    // completely alone — those are unconfirmed local writes we still WANT to
    // push, not leftovers from a wiped table.
    //
    // Deliberately NOT a #Predicate doing the "id not in serverIds" check: SwiftData's
    // #Predicate macro compiles down to SQL against the LOCAL store, and a
    // dynamically-sized Set fetched over the network mid-call isn't something
    // you want to lean on a query-compiler macro to handle correctly. Cheaper,
    // clearer, and just as correct here: pull the (small) candidate set with a
    // simple equality predicate, then filter in plain Swift.
    func pruneStaleSyncedRows() async {
        let connector = ServiceLocator.shared.databaseConnector
        guard connector.isAuthenticated else {
            logger.notice("[MessagesViewModel] prune: offline, skipping")
            return
        }
        let supabase = connector.supabaseClient

        struct IdRow: Decodable, Hashable { let id: UUID }

        do {
            // 1) What does the server actually have right now — id-only, cheap.
            let serverChannelRows: [IdRow] = try await supabase.from("channels").select("id").execute().value
            let serverMessageRows: [IdRow] = try await supabase.from("global_message_queue").select("id").execute().value
            let liveChannelIds = Set(serverChannelRows.map(\.id))
            let liveMessageIds = Set(serverMessageRows.map(\.id))

            // 2) Local .synced rows whose id ISN'T in that snapshot are stale —
            //    delete messages first (the "many" side), channels after, same
            //    FK-respecting order as the README's drop statements.
            let syncedRaw = MessageSyncStatus.synced.rawValue

            let messageDescriptor = FetchDescriptor<LocalMessage>(
                predicate: #Predicate<LocalMessage> { $0.syncStatusRaw == syncedRaw }
            )
            let staleMessages = (try? modelContext.fetch(messageDescriptor))?
                .filter { !liveMessageIds.contains($0.id) } ?? []
            for message in staleMessages {
                modelContext.delete(message)
            }

            let channelDescriptor = FetchDescriptor<LocalChannel>(
                predicate: #Predicate<LocalChannel> { $0.syncStatusRaw == syncedRaw }
            )
            let staleChannels = (try? modelContext.fetch(channelDescriptor))?
                .filter { !liveChannelIds.contains($0.id) } ?? []
            for channel in staleChannels {
                // deleteRule: .nullify (see LocalChannel.messages) means any
                // LocalMessage still pointing at this channel gets its `channel`
                // set to nil automatically — it does NOT cascade-delete those
                // messages. A message that was ALSO stale was already removed
                // above; a message that's still .pending just survives with
                // channel == nil, and picks up a fresh "global" channel the next
                // time findOrCreateGlobalChannel() runs.
                modelContext.delete(channel)
            }

            logger.notice("[MessagesViewModel] pruned \(staleMessages.count) stale message(s), \(staleChannels.count) stale channel(s)")
            try? modelContext.save()
            refreshFromLocalStore()
        } catch {
            logger.error("[MessagesViewModel] prune: fetch error:\(error)")
        }
    }
}
