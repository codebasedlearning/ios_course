// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import Network
import Combine

fileprivate let logger = PredefinedLogger.dataLogger

final class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    // ── OLD Combine version (kept for comparison, not deleted) ──────────────
    //
    // /*
    //   - Unlike PassthroughSubject, it must be initialized with an initial value
    //     and always maintains a "current" value.
    //   - Internal Write Access -> receives network status updates from NWPathMonitor,
    //     i.e. here data enters the system.
    //  */
    // private let eventSubject = CurrentValueSubject<Bool, Never>(false)
    //
    // /*
    //   - External Read Access, i.e. external code can only subscribe and observe
    //   - Public - accessible to anyone using NetworkMonitor
    //   - Broadcasting - distributes network status to subscribers
    //   - eraseToAnyPublisher is a pure type erasor (wrapper)
    //
    //   - when later .sink is called:
    //       - AnyPublisher forwards the subscription request to the underlying eventSubject
    //       - eventSubject registers this new subscriber in its internal list
    //       - A connection is established: eventSubject → subscriber
    //  */
    // var eventPublisher: AnyPublisher<Bool, Never> { eventSubject.eraseToAnyPublisher() }
    // ──────────────────────────────────────────────────────────────────────

    // NEW: AsyncStream replaces CurrentValueSubject — but it is NOT a drop-in
    // replacement, and the gap is exactly what caused the reported bug.
    //
    // CurrentValueSubject (Combine publishers generally) are MULTICAST: any
    // number of .sink subscribers each independently see every value. An
    // AsyncStream is NOT multicast — it's one sequence with, conceptually,
    // ONE reader. If two different `for await` loops iterate the very same
    // AsyncStream instance, each yielded value is delivered to exactly ONE of
    // the waiting iterators (whichever called next() first), never to both.
    // Values get split between the two consumers, essentially at the mercy of
    // scheduling — not duplicated.
    //
    // This file used to expose one `let eventStream: AsyncStream<Bool>`, and
    // BOTH NetworkViewModel and MessagesViewModel iterated it (the latter to
    // detect the offline→online edge and drain its outbox). That only ever
    // "worked" while there was a single listener; the moment a second one
    // showed up, they started racing for every path-change event — which is
    // why connectivity looked wrong at launch and after toggling the network:
    // purely a question of which of the two `for await` loops happened to be
    // suspended on .next() when a value landed.
    //
    // Fix: hand out a FRESH AsyncStream per subscriber via makeEventStream(),
    // and fan every NWPathMonitor update out to ALL of them — restoring the
    // broadcast semantics Combine gave us for free. Each new subscriber is
    // immediately seeded with the current known status (CurrentValueSubject's
    // "late subscribers get the current value too" behaviour), so nobody has
    // to wait for the next actual network change to find out where things
    // stand right now.
    private var continuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
    private let lock = NSLock()
    private var lastKnownStatus = false // pessimistic until NWPathMonitor reports in

    func makeEventStream() -> AsyncStream<Bool> {
        let (stream, continuation) = AsyncStream.makeStream(of: Bool.self)
        let id = UUID()

        // Registering the continuation and seeding it both have to happen
        // under the SAME lock acquisition — not two separate critical
        // sections. broadcast() (running on NWPathMonitor's own background
        // queue) also takes this lock before it can see/yield to this
        // continuation. If the seed yield happened AFTER releasing the lock
        // here, a real broadcast() could slip in between "insert into dict"
        // and "yield the seed", landing its (correct, current) value in the
        // stream BEFORE the (now-stale) seed catches up — i.e. the freshest
        // value gets immediately overwritten by an outdated one right after
        // it. With a 2-state Bool, that out-of-order pair is indistinguishable
        // from "the signal got inverted" — which is exactly the symptom this
        // was producing on the first real toggle after launch. Holding the
        // lock across the yield closes that gap: broadcast() can't observe
        // this continuation until the seed has already been queued ahead of it.
        lock.lock()
        continuations[id] = continuation
        continuation.yield(lastKnownStatus) // seed with "now", atomically with registration
        lock.unlock()

        continuation.onTermination = { [weak self] _ in
            guard let self else { return }
            self.lock.lock()
            self.continuations.removeValue(forKey: id)
            self.lock.unlock()
        }
        return stream
    }

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
            let status = switch(path.status) {
                case .satisfied: "satisfied"
                case .unsatisfied: "unsatisfied"
                case .requiresConnection: "requiresConnection"
                case _: "unknown"
                //case .satisfied(interface: .cellular): "cellular"
                //case .unsatisfied(interface: .cellular): "cellular-unavailable"
                //case .satisfied(interface: .wiredEthernet): "wired"
            }
            logger.notice("[NetworkMonitor] status \(status)")
            self?.broadcast(path.status == .satisfied)
        }
        // this is where the callback executes; called a queue because of how tasks are scheduled
        // (typically uses one background thread)
        monitor.start(queue: queue)
    }

    // The other half of the fix: fan one path-update out to every subscriber's
    // own continuation, instead of yielding into a single shared one.
    private func broadcast(_ isConnected: Bool) {
        lock.lock()
        lastKnownStatus = isConnected
        let targets = continuations.values
        let count = targets.count
        lock.unlock()
        // Diagnostic: this fires the moment NWPathMonitor itself reports a
        // change, BEFORE any consumer (NetworkViewModel, MessagesViewModel)
        // gets a chance to react. If this line never shows up in the console
        // when toggling the network, the problem is upstream of all the
        // AsyncStream plumbing — NWPathMonitor isn't seeing the change at all
        // (wrong interface, Simulator quirk, etc.) — not a bug in this file.
        logger.notice("[NetworkMonitor] path changed → \(isConnected), fanning out to \(count) subscriber(s)")
        for continuation in targets {
            continuation.yield(isConnected)
        }
    }

    deinit {
        monitor.cancel()
        lock.lock()
        let targets = continuations.values
        continuations.removeAll()
        lock.unlock()
        for continuation in targets {
            continuation.finish()
        }
    }
}

