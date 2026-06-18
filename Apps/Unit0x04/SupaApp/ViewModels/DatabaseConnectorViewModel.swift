// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import Combine
import Supabase

fileprivate let logger = PredefinedLogger.dataLogger

// ── Combine consumption side — see DatabaseConnector.swift for the full sketch ──
//
// This ViewModel sits on the Combine side of the bridge:
//   connector.eventPublisher           — an AnyPublisher<DatabaseConnectorEvent, Never>
//   .receive(on: DispatchQueue.main)   — operator: hop to the main thread for UI writes
//   .sink { [weak self] event in … }   — subscriber: runs the closure on each event
//   .store(in: &cancellables)          — keeps the AnyCancellable alive as long as self
//
// The [weak self] in the sink closure is not optional style — it is mandatory.
// Without it there is a reference cycle:
//   self (ViewModel) → cancellables (Set) → AnyCancellable → sink closure → self
// [weak self] breaks the last edge; 'guard let self' re-strengthens it safely
// inside the closure so the body can use self normally.
//
// With pure Swift Concurrency this class would instead spawn a Task and run
//   for await event in connector.eventStream { … }
// Cancellation would be handled by cancelling the Task (no Set needed), and
// there would be no retain-cycle risk because the closure disappears with it.
// ─────────────────────────────────────────────────────────────────────────────

@Observable
@MainActor
class DatabaseConnectorViewModel {
    var isAuthenticated = false
    var userProfile: UserProfile? = nil
    var lastInfo: String = ""

    // Same problem as DatabaseConnector.lastKnownUserId, one layer up: ContentView
    // used to key its tab-switch on isAuthenticated directly, i.e. on the SAME
    // live, SDK-driven signal that's documented to spuriously report false while
    // offline (issue #630 again). Result: compose offline on the Messages tab,
    // the flaky flag blips false, .onChange fires, TabView yanks you back to
    // Login — looks exactly like "my message vanished" even on the rare occasion
    // the message itself was saved fine.
    //
    // hasKnownIdentity mirrors connector.lastKnownUserId's lifecycle instead:
    // seeded from it at startup, set true on a real .signedIn, and — this is
    // the point — never set false by the stream's .signedOut case, only by this
    // class's own signOut() below. So a network hiccup can't move it.
    //
    // `= false` here is NOT the real seed value — it only exists so every
    // stored property has a default, which is what lets init() below read
    // `connector` (itself just a default-valued property) at all. Swift's
    // two-phase init won't let you touch self/self's properties for ANY
    // reason until every stored property has SOME value, even one you're
    // about to immediately overwrite. The real seed happens on the first
    // line of init().
    var hasKnownIdentity: Bool = false

    private var connector = ServiceLocator.shared.databaseConnector

    // ── OLD Combine version (kept for comparison, not deleted) ──────────────
    //
    // private var cancellables = Set<AnyCancellable>()
    //
    // init() {
    //     connector.eventPublisher
    //         .receive(on: DispatchQueue.main)
    //         // also possible: .assign(to: \.isConnected, on: self)
    //         .sink { [weak self] event in   // [weak self] breaks the retain cycle: self → cancellables → sink → self
    //             guard let self else { return }
    //             switch event {
    //             case .signedIn(let userProfile, _):
    //                 logger.notice("[DatabaseConnectorViewModel] user \(userProfile.displayname) signed in")
    //                 self.isAuthenticated = true
    //                 self.userProfile = userProfile
    //                 self.lastInfo = "signed in"
    //             case .signedOut:
    //                 self.isAuthenticated = false
    //                 self.userProfile = nil
    //                 self.lastInfo = "signed out"
    //                 logger.notice("[DatabaseConnectorViewModel] user signed out")
    //             case .broadcast(payload: let payload):
    //                 logger.notice("[DatabaseConnectorViewModel] broadcast: \(payload)")
    //                 self.lastInfo = payload["msg"] ?? ""
    //             }
    //         }
    //         .store(in: &cancellables)
    // }
    // ──────────────────────────────────────────────────────────────────────

    // NEW: AsyncStream replaces the Combine pipeline. @MainActor on the class means
    // the Task below inherits main-actor isolation, so no receive(on:) hop is needed.
    // [weak self] + guard-let mirrors the old sink closure exactly, for the same
    // reason: self stores listenTask, listenTask's closure must not store self.
    //
    // nonisolated(unsafe): deinit can't be actor-isolated even on an @MainActor
    // class (dealloc can happen off-main, and deinit is synchronous — no hopping
    // to the main actor mid-deinit). Without this, `listenTask?.cancel()` in
    // deinit fails to compile with "Main actor-isolated property 'listenTask'
    // can not be referenced from a nonisolated context". Safe here because
    // Task.cancel() is thread-safe and nothing else holds self once deinit runs.
    nonisolated(unsafe) private var listenTask: Task<Void, Never>?

    init() {
        hasKnownIdentity = connector.lastKnownUserId != nil // survives a cold relaunch while offline

        listenTask = Task { [weak self, connector] in
            for await event in connector.eventStream {
                guard let self else { return }
                switch event {
                case .signedIn(let userProfile, _):
                    logger.notice("[DatabaseConnectorViewModel] user \(userProfile.displayname) signed in")
                    self.isAuthenticated = true
                    self.userProfile = userProfile
                    self.lastInfo = "signed in"
                    self.hasKnownIdentity = true
                case .signedOut:
                    self.isAuthenticated = false
                    self.userProfile = nil
                    self.lastInfo = "signed out"
                    logger.notice("[DatabaseConnectorViewModel] user signed out")
                case .broadcast(payload: let payload):
                    logger.notice("[DatabaseConnectorViewModel] broadcast: \(payload)")
                    self.lastInfo = payload["msg"] ?? ""
                }
            }
        }
    }

    deinit {
        listenTask?.cancel()
    }

    func signIn(email: String, password: String) {
        connector.signIn(email: email, password: password)
    }
    
    func signOut() {
        hasKnownIdentity = false // explicit user intent — the one case this SHOULD flip immediately
        connector.signOut()
    }
    
    func broadcast(message: String) {
        connector.broadcast(payload:["msg":message])
    }
}
