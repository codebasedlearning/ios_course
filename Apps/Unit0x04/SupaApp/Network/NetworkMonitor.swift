// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import Network
import Combine

fileprivate let logger = PredefinedLogger.dataLogger

final class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    /*
      - Unlike PassthroughSubject, it must be initialized with an initial value
        and always maintains a "current" value.
      - Internal Write Access -> receives network status updates from NWPathMonitor,
        i.e. here data enters the system.
     */
    private let eventSubject = CurrentValueSubject<Bool, Never>(false)

    /*
      - External Read Access, i.e. external code can only subscribe and observe
      - Public - accessible to anyone using NetworkMonitor
      - Broadcasting - distributes network status to subscribers
      - eraseToAnyPublisher is a pure type erasor (wrapper)
     
      - when later .sink is called:
          - AnyPublisher forwards the subscription request to the underlying eventSubject
          - eventSubject registers this new subscriber in its internal list
          - A connection is established: eventSubject → subscriber
     */
    var eventPublisher: AnyPublisher<Bool, Never> { eventSubject.eraseToAnyPublisher() }

    init() {
        /*
          - connect the monitor to the lambda, run for every network status change event
         
          - somewhere: let myMonitor = NetworkMonitor()
          - NetworkMonitor holds monitor
          - monitor holds pathUpdateHandler
          - closure holds (weak/strong) self
         => all referenced, i.e. nothing is ever deallocates => memory leaks
         
          - using [weak self] (capture)
          - makes self optional inside the closure
         */
        monitor.pathUpdateHandler = { [weak self] path in
            self?.eventSubject.send(path.status == .satisfied)
        }
        // this is where the callback executes; called a queue because of how tasks are scheduled
        // (typically uses one background thread)
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

