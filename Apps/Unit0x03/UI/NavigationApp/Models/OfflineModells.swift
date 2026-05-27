// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

import Foundation
import Combine

enum ConnectionState: Int {
    case error
    case offline
    case online
}

class OfflineModeManager {
    private(set) var state: ConnectionState = .offline
    var isOnline: Bool { state == .online }
    
    public let modePublisher = PassthroughSubject<ConnectionState, Never>()

    func goOffline() {
        state = .offline
        print("App is now offline.")
        modePublisher.send(state)
    }

    func goOnline() {
        state = .online
        print("App is now online.")
        modePublisher.send(state)
    }

    func goError() {
        state = .error
        print("App is now in error mode.")
        modePublisher.send(state)
    }
}

@Observable
class OfflineViewModel {
    private(set) var currentState: ConnectionState = .offline
    
    private var cancellables = Set<AnyCancellable>()
    private var manager = ServiceLocator.shared.offlineModeManager
    
    init() {
        manager.modePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.currentState = state }
            .store(in: &cancellables)
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
