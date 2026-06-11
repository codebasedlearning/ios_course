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
class DatabaseConnectorViewModel {
    var isAuthenticated = false
    var userProfile: UserProfile? = nil
    var lastInfo: String = ""
    
    private var connector = ServiceLocator.shared.databaseConnector
    private var cancellables = Set<AnyCancellable>()

    init() {
        connector.eventPublisher
            .receive(on: DispatchQueue.main)
            // also possible: .assign(to: \.isConnected, on: self)
            .sink { [weak self] event in   // [weak self] breaks the retain cycle: self → cancellables → sink → self
                guard let self else { return }
                switch event {
                case .signedIn(let userProfile, _):
                    logger.notice("[DatabaseConnectorViewModel] user \(userProfile.displayname) signed in")
                    self.isAuthenticated = true
                    self.userProfile = userProfile
                    self.lastInfo = "signed in"
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
            .store(in: &cancellables)
    }

    func signIn(email: String, password: String) {
        connector.signIn(email: email, password: password)
    }
    
    func signOut() {
        connector.signOut()
    }
    
    func broadcast(message: String) {
        connector.broadcast(payload:["msg":message])
    }
}
