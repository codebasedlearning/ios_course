// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 UserViewModel is a thin facade over AuthService.

 The VM owns *no* user data of its own — it just:
   - exposes the auth service's currentUser to the View
   - forwards login()/logout() to the service
   - offers a couple of pre-formatted, View-friendly accessors
     (displayName, isSignedIn) so the View can stay free of
     optional-handling clutter

 Why this is an improvement over the previous "VM holds user string"
 version:
   - Domain logic (which user is signed in) now lives in the Service,
     not in a ViewModel. The VM is back to being just UI glue.
   - The same AuthService and User can be observed by multiple VMs
     and multiple screens without duplicating state — there is one
     source of truth.
   - Testability: in a test you can substitute a mock AuthService.
     Try doing that with a hard-coded state machine baked into a VM.

 Why we still need a UserViewModel at all (couldn't the View just
 observe the AuthService directly?):
   - The 'displayName' and 'isSignedIn' helpers are VM-shaped concerns
     (UI presentation), not Service-shaped concerns (session state).
     Keeping them out of AuthService preserves the layering.
   - It gives us a place to add user-related UI state (e.g. "edit
     profile" form fields) without polluting the Service.
   - Future use cases (e.g. inject the service via constructor in
     a test) plug in here without touching the View.
 */
@MainActor
@Observable
class UserViewModel {
    private let auth: AuthService

    init(auth: AuthService = ServiceLocator.shared.authService) {
        self.auth = auth
    }

    // Pass-through to the service. The Observation framework follows
    // the chain into 'auth' and tracks the dependency on currentUser
    // correctly — so a View reading 'userViewModel.currentUser' will
    // re-render when AuthService.currentUser changes.
    var currentUser: User? { auth.currentUser }

    // View-friendly accessors. Keeps the View free of optional juggling.
    var displayName: String { currentUser?.name ?? "(not signed in)" }
    var isSignedIn: Bool    { currentUser != nil }

    func login()  { auth.login() }
    func logout() { auth.logout() }
}
