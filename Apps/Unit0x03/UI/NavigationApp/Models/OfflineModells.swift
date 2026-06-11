// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

import Foundation
// import Combine                           // OLD: No longer needed with AsyncStream

/*
 Benefits of the new AsyncStream approach:
  - no Combine dependency, pure Swift Concurrency
  - less boilerplate, no cancellables storage needed
  - clearer intent, 'for await' is more readable than sink
  - better lifecycle, Task cancellation is explicit and clean
  - still UI-agnostic, model layer has zero UI framework dependencies
 */

enum ConnectionState: Int, Hashable {
    case error
    case offline
    case online
    
    /// Returns a localized display name for the connection state.
    /// In Xcode, add these keys to your String Catalog (Localizable.xcstrings):
    /// - "connection_state_error"
    /// - "connection_state_offline" 
    /// - "connection_state_online"
    var displayName: String {
        switch self {
        case .error:
            return String(localized: "connection_state_error", 
                         defaultValue: "Error",
                         comment: "Connection state when there's an error")
        case .offline:
            return String(localized: "connection_state_offline",
                         defaultValue: "Offline", 
                         comment: "Connection state when offline")
        case .online:
            return String(localized: "connection_state_online",
                         defaultValue: "Online",
                         comment: "Connection state when online")
        }
    }
}

class OfflineModeManager {
    private(set) var state: ConnectionState = .offline
    var isOnline: Bool { state == .online }
    
    // OLD: Combine-based approach
    // public let modePublisher = PassthroughSubject<ConnectionState, Never>()
    
    // NEW: AsyncStream-based approach
    // Continuation allows us to push values into the stream from outside
    private var continuation: AsyncStream<ConnectionState>.Continuation?
    
    // NEW: lazy so the stream is created only when first accessed
    public lazy var stateStream: AsyncStream<ConnectionState> = {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.yield(self.state)  // Send initial state immediately
            continuation.onTermination = { @Sendable _ in } // cleanup here if needed
        }
    }()

    func goOffline() {
        state = .offline
        print("App is now offline.")
        // modePublisher.send(state)        // OLD: Combine
        continuation?.yield(state)          // NEW: AsyncStream
    }

    func goOnline() {
        state = .online
        print("App is now online.")
        // modePublisher.send(state)        // OLD: Combine
        continuation?.yield(state)          // NEW: AsyncStream
    }

    func goError() {
        state = .error
        print("App is now in error mode.")
        // modePublisher.send(state)        // OLD: Combine
        continuation?.yield(state)          // NEW: AsyncStream
    }
}

@Observable
class OfflineViewModel {
    private(set) var currentState: ConnectionState = .offline
    
    // OLD: Combine-based approach
    // private var cancellables = Set<AnyCancellable>()
    
    // NEW: AsyncStream-based approach
    private var streamTask: Task<Void, Never>?
    
    private var manager = ServiceLocator.shared.offlineModeManager
    
    init() {
        // OLD: Combine sink/store pattern
        // manager.modePublisher
        //     .receive(on: DispatchQueue.main)
        //     .sink { [weak self] state in self?.currentState = state }
        //     .store(in: &cancellables)
        
        // NEW: AsyncStream with Task
        // Task automatically inherits @MainActor from @Observable class if needed,
        // or we can explicitly mark the closure as @MainActor
        streamTask = Task { @MainActor [weak self] in
            guard let self else { return }
            // for await automatically suspends and waits for each value
            for await state in self.manager.stateStream {
                self.currentState = state
            }
        }
    }
    
    deinit {
        streamTask?.cancel()            // clean up the task when ViewModel is deallocated
    }
    
    func goOffline() { manager.goOffline() }
    func goOnline() { manager.goOnline() }
    func goError() { manager.goError() }
}

class OfflineData {
    private static let postCollection: [Post] = [
        Post(id: 1, userId: 1, title: "post 1", body: "body 1"),
        Post(id: 2, userId: 1, title: "post 2", body: "body 2")
    ]
    private static let postError: [Post] = [
        Post(id: 0, userId: 1, title: "error", body: "body error"),
    ]

    private static let commentCollection: [Comment] = [
        Comment(id: 11, postId: 1, name: "name 1.1", email: "1.1@example.com", body: "body 1.1"),
        Comment(id: 12, postId: 1, name: "name 1.2", email: "1.2@example.com", body: "body 1.2"),
        Comment(id: 21, postId: 2, name: "name 2.1", email: "2.1@example.com", body: "body 2.1"),
        Comment(id: 22, postId: 2, name: "name 2.2", email: "2.2@example.com", body: "body 2.2"),
        Comment(id: 23, postId: 2, name: "name 2.3", email: "2.3@example.com", body: "body 2.3"),
    ]

    private static let commentError: [Comment] = [
        Comment(id: 99, postId: 0, name: "error", email: "error@example.com", body: "body error"),
    ]

    static func getPosts(state: ConnectionState) -> [Post] {
        switch state {
        case .online:
            return []
        case .offline:
            return postCollection
        case .error:
            return postError
        }
    }

    static func getComments(forPostId postId: Int, state: ConnectionState) -> [Comment] {
        switch state {
        case .online:
            return []
        case .offline:
            switch postId {
            case 1:
                return Array(commentCollection[0...1])
            case 2:
                return Array(commentCollection[2...4])
            default:
                return []
            }
        case .error:
            return commentError
        }
    }
}
