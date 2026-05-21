// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 SecretsViewModel demonstrates *fan-out* on the Model→VM arrow: a SECOND
 consumer of AuthService, completely independent of UserViewModel.

 There is no subscription code here at all. Because AuthService is
 @Observable, every reader gets dependency-tracked individually.
 Adding the next consumer of "is the user signed in?" costs zero plumbing
 — you just read auth.currentUser and the Observation framework wires
 the View update.

 Compare with the sensor VMs (PowerViewModel, TemperatureViewModel,
 BatteryViewModel, …): those manage Combine cancellables / Task
 handles / NotificationCenter observers explicitly, because their
 Models are "raw" and use an explicit notification channel. AuthService
 trades that purity for ergonomics — and this VM is what cashes in.

 The three exposed properties are all computed pass-throughs of
 auth.currentUser. Reading any one of them registers a dependency on
 auth.currentUser, so the View re-renders when login()/logout() runs.

 Naming convention: a "session token" is a fake stand-in for any
 user-derived secret data — your access token, an API key, a row of
 personalised content. The synthetic value just has to be visibly
 different per user.
 */
@MainActor
@Observable
class SecretsViewModel {
    private let auth: AuthService

    init(auth: AuthService = ServiceLocator.shared.authService) {
        self.auth = auth
    }

    /// True while a user is signed in. Drives whether SecretsView appears.
    var isVisible: Bool { auth.currentUser != nil }

    /// A fake per-user "session token". In a real app this would be a
    /// JWT, an OAuth bearer, a row of profile data — anything that only
    /// makes sense in the context of a specific signed-in user.
    var sessionToken: String? {
        auth.currentUser.map { "tok_\(String($0.id.uuidString.prefix(8)))" }
    }
}
