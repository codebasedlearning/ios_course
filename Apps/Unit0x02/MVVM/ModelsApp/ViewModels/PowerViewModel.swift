// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import Combine

/*
 PowerViewModel subscribes to the Combine PassthroughSubject exposed
 by PowerSensor. Compared to NotificationCenter this is type-safe and
 lifecycle-managed (the AnyCancellable cleans up on dealloc).
 */
@Observable
class PowerViewModel {
    var currentPower: Int? = nil // optional, no value at start

    // AnyCancellable represents a Combine subscription that can be cancelled.
    // Storing it keeps the subscription alive; when the set is deallocated,
    // all subscriptions cancel automatically.
    // In a way this is Combine's equivalent of weak self for memory management.
    // It prevents leaks while ensuring automatic cleanup.
    private var cancellables = Set<AnyCancellable>()
    private var sensor = ServiceLocator.shared.powerSensor

    init() {
        sensor.powerPublisher
            .receive(on: DispatchQueue.main)    // not recommended in combination with SwiftUI: .receive(on: RunLoop.main)
            .sink { [weak self] power in self?.currentPower = power } // Any​Cancellable-handle to Closure not stored, would be gone after init
            .store(in: &cancellables)  // Adds the subscription to the set; without this, subscription would cancel immediately
    }

    func startMonitoring() {
        sensor.startMonitoring()
    }

    func stopMonitoring() {
        sensor.stopMonitoring()
        currentPower = nil
    }
}
