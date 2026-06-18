// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import Combine
import Supabase

fileprivate let logger = PredefinedLogger.databaseLogger

struct UserProfile: Decodable, Hashable {
    let id: UUID
    let email: String

    var displayname: String { "\(email.displayname)"}
}

enum DatabaseError: Error, CustomStringConvertible {
    case invalidUserProfile
    case unexpected(message: String)

    var description: String {
        switch self {
        case .invalidUserProfile:
            return "Invalid user profile."
        case .unexpected(let message):
            return "Unexpected error: \(message)"
        }
    }
}

enum DatabaseConnectorEvent {
    case signedIn(userProfile: UserProfile, session:Session?)
    case signedOut
    case broadcast(payload:[String:String])
}

// ── Combine vs. Swift Concurrency — a sketch ─────────────────────────────────
//
// This file intentionally uses BOTH paradigms so they can be compared directly.
//
// COMBINE (import Combine)
//   Apple's reactive-streams library (2019).  The model is a declarative
//   pipeline:  Publisher ──operators──► Subscriber
//
//   • A Publisher emits values over time (zero to many), then optionally a
//     completion or error.  Nothing flows until a subscriber attaches.
//   • Operators transform the stream in place: .map, .filter, .debounce,
//     .receive(on:), …  — they return new publishers, so pipelines compose.
//   • Subscribers attach via .sink { } (closure) or .assign(to:on:).
//     Each subscription returns an AnyCancellable; you must store it (usually
//     in a Set<AnyCancellable>).  When the AnyCancellable is released the
//     subscription cancels automatically.
//   • Push-based: the publisher drives delivery — the subscriber just reacts.
//
//   Lifecycle hazard: a closure inside .sink captures self by default.
//   If self also owns the cancellables Set, you get a retain cycle:
//     ViewModel → cancellables → sink-closure → ViewModel  (never freed)
//   Breaking it requires [weak self] + guard let self (see ViewModel).
//
// SWIFT CONCURRENCY (async/await · Task · for-await-in)
//   Structured concurrency built into the language (Swift 5.5, 2021).
//
//   • async functions suspend at 'await' without blocking a thread; the
//     runtime resumes them when the awaited work is ready.
//   • AsyncSequence is the async counterpart of Publisher.  You iterate it
//     with 'for await value in sequence { }' inside a Task.
//   • Pull-based: the for-await loop requests the next element; nothing is
//     delivered until the loop iteration asks for it.
//   • Cancellation is structural: cancelling a parent Task propagates to all
//     child Tasks and unblocks any suspended for-await loop at the next
//     cooperative cancellation point.  No AnyCancellable, no retain cycles.
//   • @MainActor replaces manual DispatchQueue.main.async for UI updates.
//
// HOW THEY MEET IN THIS FILE
//   The Supabase Swift SDK exposes its streaming APIs as AsyncSequences:
//     client.auth.authStateChanges   — AsyncSequence<(AuthChangeEvent, Session?)>
//     channel.postgresChange(...)    — AsyncSequence of database row actions
//     channel.broadcastStream(...)   — AsyncSequence of broadcast payloads
//   These are consumed here with 'for await' loops inside Tasks (concurrency).
//
//   The ViewModels are built around Combine because @Observable + SwiftUI
//   observation wires naturally to Combine pipelines, and operators like
//   .debounce and .receive(on:) are concise for UI-update plumbing.
//
//   To bridge the gap this file uses Combine Subjects as adapters:
//     CurrentValueSubject — holds the current auth state; ViewModels subscribe
//                           with .sink and are notified on every change.
//     PassthroughSubject  — fires a one-shot signal when the DB table changes;
//                           MessagesViewModel debounces it before fetching.
//
//   A fully async-native design would replace Subjects with AsyncStream and
//   the ViewModel .sink calls with Tasks running for-await loops — trading
//   Combine's operator richness for structured cancellation and actor safety.
//   Neither is universally superior; knowing both is the goal here.
// ─────────────────────────────────────────────────────────────────────────────

final class DatabaseConnector {
    private let client: SupabaseClient

    // ── OLD Combine version (kept for comparison, not deleted) ──────────────
    //
    // private let eventSubject = CurrentValueSubject<DatabaseConnectorEvent, Never>(.signedOut)
    //
    // // same idea as in NetworkMonitor
    // var eventPublisher: AnyPublisher<DatabaseConnectorEvent, Never> { eventSubject.eraseToAnyPublisher() }
    // ──────────────────────────────────────────────────────────────────────

    // expose the underlying Supabase SDK client for direct queries
    var supabaseClient: SupabaseClient { client }

    // NEW: AsyncStream replaces CurrentValueSubject. Only DatabaseConnectorViewModel
    // consumes this, so single-consumer AsyncStream semantics are fine. The "always
    // has a current value" behaviour of CurrentValueSubject is replicated by yielding
    // .signedOut right after creating the stream, below in init().
    let eventStream: AsyncStream<DatabaseConnectorEvent>
    private let eventContinuation: AsyncStream<DatabaseConnectorEvent>.Continuation

    private let broadcastChannelName = "mobileApp-channel"
    private let broadcastEventName = "mobileApp-event"          // "*" does not work...
    let broadcastChannel: RealtimeChannelV2                          // broadcast channel — assigned once in init

    private let dataChannelName = "messages-changes"
    let dataChannel: RealtimeChannelV2                      // postgres change channel

    // Postgres changes channel — subscribed once in init(), exactly like the broadcast channel.
    // The SDK automatically re-joins all channels with the updated JWT whenever setAuth() is
    // called internally (on sign-in and sign-out), so no manual start/stop per sign-in is needed.
    // Subscribing inside the authStateChanges callback races against the SDK's own setAuth()
    // listener — the subscription goes out with the stale anon key, events are 401'd server-side,
    // and the SDK silently drops them, leaving for-await-in permanently silent.
    //
    // ── OLD Combine version (kept for comparison, not deleted) ──────────────
    //
    // private let messagesChangedSubject = PassthroughSubject<Void, Never>()
    // var messagesChangedPublisher: AnyPublisher<Void, Never> { messagesChangedSubject.eraseToAnyPublisher() }
    // ──────────────────────────────────────────────────────────────────────

    // NEW: AsyncStream replaces PassthroughSubject. No initial value to seed —
    // PassthroughSubject never had one either, it only ever signalled "something changed".
    let messagesChangedStream: AsyncStream<Void>
    private let messagesChangedContinuation: AsyncStream<Void>.Continuation

    // external code may read these but only DatabaseConnector itself should write them
    private(set) var isAuthenticated = false
    private(set) var userProfile: UserProfile? = nil

    // ── Why a SECOND copy of "who is signed in" exists ──────────────────────
    //
    // isAuthenticated/userProfile above are driven entirely by the Supabase SDK's
    // authStateChanges stream — and that stream has a documented habit of
    // reporting .signedOut (or .initialSession with session == nil) even though
    // a perfectly valid refresh token is sitting in the keychain. Not a
    // hypothetical: see supabase-swift issue #630 ("auto-refreshing of tokens
    // can fail and never restart again" — airplane mode is the literal repro
    // steps) and org discussion #35158 (session straight-up missing after an
    // app relaunch). It's a known soft spot, not something this app can fix in
    // a third-party SDK.
    //
    // Composing a message is a 100%-local SwiftData write (see LocalMessage /
    // MessagesViewModel.insertMessage) — it has no business being blocked by a
    // live, network-derived flag that's known to occasionally lie. So:
    //   - lastKnownUserId/lastKnownEmail are written the moment we see a REAL
    //     profile (below), and persisted in UserDefaults so they survive an
    //     app relaunch while offline.
    //   - they are cleared ONLY by an explicit, user-initiated signOut() call —
    //     never by the authStateChanges .signedOut case, since that case fires
    //     for "you actually signed out" and "the SDK gave up refreshing" alike,
    //     and this app has no way to tell those two apart from here.
    //   - isAuthenticated/userProfile stay authoritative for anything that
    //     actually talks to the network (showing a login screen, the push in
    //     syncPendingMessages) — this is purely the offline-safe fallback for
    //     "whose row is this," not a replacement for real auth state.
    private static let lastKnownUserIdKey = "DatabaseConnector.lastKnownUserId"
    private static let lastKnownEmailKey = "DatabaseConnector.lastKnownEmail"

    var lastKnownUserId: UUID? {
        UserDefaults.standard.string(forKey: Self.lastKnownUserIdKey).flatMap(UUID.init)
    }
    var lastKnownEmail: String? {
        UserDefaults.standard.string(forKey: Self.lastKnownEmailKey)
    }

    private func rememberIdentity(_ profile: UserProfile) {
        UserDefaults.standard.set(profile.id.uuidString, forKey: Self.lastKnownUserIdKey)
        UserDefaults.standard.set(profile.email, forKey: Self.lastKnownEmailKey)
    }

    private func forgetIdentity() {
        UserDefaults.standard.removeObject(forKey: Self.lastKnownUserIdKey)
        UserDefaults.standard.removeObject(forKey: Self.lastKnownEmailKey)
    }

    init() {
        let (eventStream, eventContinuation) = AsyncStream.makeStream(of: DatabaseConnectorEvent.self)
        self.eventStream = eventStream
        self.eventContinuation = eventContinuation
        self.eventContinuation.yield(.signedOut) // seed, mirrors CurrentValueSubject's initial value

        let (messagesChangedStream, messagesChangedContinuation) = AsyncStream.makeStream(of: Void.self)
        self.messagesChangedStream = messagesChangedStream
        self.messagesChangedContinuation = messagesChangedContinuation

        // credentials are defined in Config/SupabaseConfig.swift — keep them out of here
        client = SupabaseClient(supabaseURL: SupabaseConfig.url, supabaseKey: SupabaseConfig.publishableKey)

        // broadcast channel
        broadcastChannel = client.realtimeV2.channel(broadcastChannelName) {
            $0.broadcast.acknowledgeBroadcasts = true
            $0.broadcast.receiveOwnBroadcasts = true
        }
        
        // data changed channel
        dataChannel = client.realtimeV2.channel(dataChannelName)

        // auth change observer
        Task {
            logger.notice("[DatabaseConnector] start observer")

            for await (event, session) in client.auth.authStateChanges {
                logger.notice("[DatabaseConnector] auth change event:\(event.rawValue)")
                switch event {
                case .signedIn, .initialSession: // maybe there is still a valid session
                    do {
                        guard let session = session,
                              let email = session.user.email else { throw DatabaseError.invalidUserProfile }
                        let userProfile = UserProfile(id: session.user.id, email: email)
                        self.isAuthenticated = true
                        self.userProfile = userProfile
                        rememberIdentity(userProfile) // see lastKnownUserId — survives a flaky/offline authStateChanges later
                        eventContinuation.yield(.signedIn(userProfile: userProfile, session: session)) // was eventSubject.send(...)
                    } catch {
                        if event == .signedIn {
                            logger.notice("[DatabaseConnector] profile error:\(error)")
                            signOut()
                        }
                    }
                case .signedOut:
                    self.isAuthenticated = false
                    self.userProfile = nil
                    eventContinuation.yield(.signedOut) // was eventSubject.send(...)
                // case .tokenRefreshed:   // handle token refresh if necessary
                // case .userUpdated:      // handle user updates if necessary
                default:
                    break
                }
            }
        }

        // broadcast listener
        Task {
            await broadcastChannel.subscribe()

            let status = "\(broadcastChannel.status)"
            logger.notice("[DatabaseConnector] channel status:\(status)")

            for await event in broadcastChannel.broadcastStream(event:broadcastEventName) {
                logger.notice("[DatabaseConnector] channel event:\(event)")

                if let payloadMember = event["payload"] {
                    switch payloadMember {
                    case .object(let dict):
                        let stringDict = dict.compactMapValues { $0.stringValue }
                        eventContinuation.yield(.broadcast(payload: stringDict)) // was eventSubject.send(...)
                    default:
                        break
                    }
                } else {
                    logger.notice("[DatabaseConnector] channel event in unknown format")
                }
            }
        }

        // postgres changes listener — subscribed early, SDK re-joins with fresh JWT on auth changes
        Task {
            // postgresChange() MUST be registered before subscribe(),
            // it configures what database changes you want to listen
            let changes = dataChannel.postgresChange(
                AnyAction.self,
                schema: "public",
                table: "global_message_queue"
            )
            await dataChannel.subscribe()
            logger.notice("[DatabaseConnector] messages realtime channel subscribed")

            for await _ in changes {
                logger.notice("[DatabaseConnector] messages table changed — signalling refetch")
                messagesChangedContinuation.yield() // was messagesChangedSubject.send() — simply reload all
            }
        }

    }

    deinit {
        // was: "// deinit { maybe something to clean up }" — now there's something to clean up:
        // finish() lets any for-await loop over these streams (in the ViewModels) end gracefully.
        // Moot in practice since DatabaseConnector is a ServiceLocator singleton that never
        // deinitialises during a normal app run — but correct is correct.
        eventContinuation.finish()
        messagesChangedContinuation.finish()
    }

    // information about state change is handled by state change in NetworkMonitor

    func signIn(email: String, password: String) {
        Task {
            do {
                logger.notice("[SupabaseConnector] sign in, email:\(email)")
                try await client.auth.signIn(email: email, password: password)
                logger.notice("[SupabaseConnector] sign in worked")
            } catch {
                logger.error("[SupabaseConnector] sign in error:\(error)")
            }
        }
    }

    func signOut() {
        // Cleared here — the one place we know for certain this is the user's
        // own intent, not the SDK's auth stream guessing. Cleared up front,
        // independent of whether the network signOut below actually succeeds:
        // once the user has asked to sign out, new local writes shouldn't keep
        // landing under their old identity regardless of what Supabase says.
        forgetIdentity()
        Task {
            do {
                logger.notice("[SupabaseConnector] sign out")
                try await client.auth.signOut()
                logger.notice("[SupabaseConnector] sign out worked")
            } catch {
                logger.error("[SupabaseConnector] sign out error:\(error)")
            }
        }
    }

    func broadcast(payload: [String: String]) {
        Task {
            do {
                try await broadcastChannel.broadcast(event: broadcastEventName, message: payload)
            } catch {
                logger.error("[SupabaseConnector] broadcast error:\(error)")
            }
        }
    }

}
