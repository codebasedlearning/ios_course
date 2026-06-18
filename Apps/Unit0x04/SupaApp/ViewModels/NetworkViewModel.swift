// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import Network
import Combine

fileprivate let logger = PredefinedLogger.dataLogger

@Observable
@MainActor
class NetworkViewModel {
    // start as false: NWPathMonitor fires its first update asynchronously, so
    // we don't actually know the state yet — better to be pessimistic than to
    // briefly flash "Online" before the first real update arrives
    var isConnected: Bool = false

    private var monitor = ServiceLocator.shared.networkMonitor

    // ── OLD Combine version (kept for comparison, not deleted) ──────────────
    //
    // private var cancellables = Set<AnyCancellable>()
    //
    // init() {
    //     /*
    //       - receive: thread-hopping to the main thread, as events arrive on the background queue
    //         and UI updates must happen on the main thread
    //       - sink: subscribe and handle each event (weak self see NetworkMonitor)
    //         returns an AnyCancellable object
    //       - store: subscription lifecycle management, because
    //         the AnyCancellable object (subscription, life-cycle aware) deallocates immediately
    //         (and subscription is cancelled instantly and you never receive events) if
    //         not stored somewhere
    //      */
    //     monitor.eventPublisher
    //         .receive(on: DispatchQueue.main)
    //         // also possible: .assign(to: \.isConnected, on: self)
    //         .sink { [weak self] isConnected in   // [weak self] breaks the retain cycle
    //             self?.isConnected = isConnected
    //             logger.notice("[NetworkViewModel] connected:\(isConnected)")
    //         }
    //         .store(in: &cancellables)
    // }
    // ──────────────────────────────────────────────────────────────────────

    // NEW: AsyncStream replaces the Combine pipeline.
    //   - The class is @MainActor, and an unstructured Task created from an
    //     actor-isolated context inherits that isolation — so the for-await loop
    //     body runs on the main actor already, no receive(on:)/DispatchQueue needed.
    //   - Unlike AnyCancellable, a Task is NOT auto-cancelled when its owner is
    //     deallocated, AND a Task whose closure captures self strongly while self
    //     stores that very Task is a genuine retain cycle (self → listenTask →
    //     closure → self) — the Combine version dodged this with [weak self]/
    //     guard-let in the sink closure, so the Task version needs the exact same
    //     move: [weak self] in the capture list + guard-let inside the loop body.
    //     Without it, deinit (and therefore the cancel() below) would never run.
    //
    //   - nonisolated(unsafe): deinit can NEVER be actor-isolated, even on an
    //     @MainActor class — deallocation can happen from any thread and deinit
    //     runs synchronously, so it can't hop to the main actor to read a MainActor-
    //     isolated property. Without this, `listenTask?.cancel()` below fails with
    //     "Main actor-isolated property 'listenTask' can not be referenced from a
    //     nonisolated context". Task.cancel() is documented thread-safe, and by the
    //     time deinit runs nothing else still holds self to race against — exactly
    //     the case this attribute exists for.
    nonisolated(unsafe) private var listenTask: Task<Void, Never>?

    init() {
        // makeEventStream(), not a shared `eventStream` property — see
        // NetworkMonitor.swift for why a single AsyncStream can't be safely
        // iterated by more than one consumer (MessagesViewModel is the other
        // one). This call gets its own private stream.
        listenTask = Task { [weak self, monitor] in
            for await isConnected in monitor.makeEventStream() {
                guard let self else { return }
                self.isConnected = isConnected
                logger.notice("[NetworkViewModel] connected:\(isConnected)")
            }
        }
    }

    deinit {
        listenTask?.cancel()
    }

    func reset() {
        logger.notice("[NetworkViewModel] reset")
    }
}
