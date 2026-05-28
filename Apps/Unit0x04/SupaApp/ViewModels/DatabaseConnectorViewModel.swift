// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import Combine
import Supabase

fileprivate let logger = PredefinedLogger.dataLogger

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
