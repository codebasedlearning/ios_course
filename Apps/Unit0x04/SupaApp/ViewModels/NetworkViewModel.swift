// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import Network
import Combine

fileprivate let logger = PredefinedLogger.dataLogger

@Observable
class NetworkViewModel {
    // start as false: NWPathMonitor fires its first update asynchronously, so
    // we don't actually know the state yet — better to be pessimistic than to
    // briefly flash "Online" before the first real update arrives
    var isConnected: Bool = false

    private var monitor = ServiceLocator.shared.networkMonitor
    private var cancellables = Set<AnyCancellable>()

    init() {
        /*
          - receive: thread-hopping to the main thread, as events arrive on the background queue
            and UI updates must happen on the main thread
          - sink: subscribe and handle each event (weak self see NetworkMonitor)
            returns an AnyCancellable object
          - store: subscription lifecycle management, because
            the AnyCancellable object (subscription, life-cycle aware) deallocates immediately
            (and subscription is cancelled instantly and you never receive events) if
            not stored somewhere
         */
        monitor.eventPublisher
            .receive(on: DispatchQueue.main)
            // also possible: .assign(to: \.isConnected, on: self)
            .sink { [weak self] isConnected in   // [weak self] breaks the retain cycle
                self?.isConnected = isConnected
                logger.notice("[NetworkViewModel] connected:\(isConnected)")
            }
            .store(in: &cancellables)
    }
    
    func reset() {
        logger.notice("[NetworkViewModel] reset")
    }
}
