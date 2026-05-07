// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

// '@MainActor' tells the compiler that all access happens on the main thread.
// For a SwiftUI ViewModel without async callbacks, this is the canonical Swift 6
// annotation — it documents intent and silences strict-concurrency warnings.
// Annotate @​Main​Actor if UI related (SwiftUI views run on the main thread):
// - SwiftUI ViewModels
// - Classes that update UI
// - Published properties accessed by views
// - Methods called from UI events
// Don't need @​Main​Actor if not UI related or background threads
// - Pure business logic classes
// - Network/Database layers
// - Model structs
//
// @Observable is a Swift macro that automatically tracks property changes.
// SwiftUI views observing this class will update when any property changes.
//
// ObservableObject and @Published is pre-iOS 17
//
@MainActor
@Observable
class UserViewModel {
    var user = "Bob"

    func login() {
        let candidates = ["Alice", "Bob", "Charly"].filter { $0 != user }
        user = candidates.randomElement() ?? user
    }
}
