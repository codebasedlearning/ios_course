// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 AuthService is a *fake* authentication service. In a real app, login()
 would call out to Sign in with Apple, OAuth, your own backend, or
 Keychain-stored credentials. Here it just rotates between three
 hard-coded users so the demo has something to show without
 infrastructure.

 Why @Observable here, instead of one of the notification channels
 used by the sensors (delegate, NotificationCenter, Combine,
 AsyncStream)?
  - "Currently signed-in user" is fundamentally session STATE, not a
    stream of events. The latest value wins; no one cares about the
    history.
  - @Observable matches that shape directly: the View reads the current
    value, SwiftUI tracks the dependency, the View re-renders on change.
  - This is the canonical iOS 17+ pattern for "session" / "settings" /
    "feature flags" / "app config" — pieces of singleton state that
    drive multiple parts of the UI.
  - AuthService is an observable Model that holds (and exposes operations on)
    another Model, User.

 In the unit's vocabulary: the sensors push *events*; the AuthService
 holds *state*. Different shapes call for different notification
 mechanisms.

 Note: AuthService is *not* @MainActor. It's called from MainActor-
 isolated VMs, so its methods effectively run on the main thread in
 practice, but leaving it un-isolated keeps it usable from any context
 (e.g. tests, background-thread persistence wiring later on).
 */
@Observable
final class AuthService {
    /// The currently signed-in user, or nil if no one is.
    /// 'private(set)' so only the service itself can mutate it — the rest
    /// of the world reads through the property and writes through login()/logout().
    private(set) var currentUser: User?

    // MARK: - Demo users
    // Exposed as 'static let' so callers (including ServiceLocator) can refer
    // to specific candidates without having to know their IDs.
    static let alice  = User(id: UUID(), name: "Alice",  email: "alice@example.com")
    static let bob    = User(id: UUID(), name: "Bob",    email: "bob@example.com")
    static let charly = User(id: UUID(), name: "Charly", email: "charly@example.com")

    private static let candidates: [User] = [alice, bob, charly]

    // MARK: - Lifecycle

    init(initialUser: User? = nil) {
        self.currentUser = initialUser
    }

    // MARK: - Auth operations

    /// "Logs in" by rotating to a different candidate than the current one.
    /// In a real app this method would be async and would talk to an
    /// identity provider. The shape of the API would otherwise be the same.
    func login() {
        let pool = Self.candidates.filter { $0.id != currentUser?.id }
        currentUser = pool.randomElement() ?? Self.candidates.first
    }

    func logout() {
        currentUser = nil
    }
}
