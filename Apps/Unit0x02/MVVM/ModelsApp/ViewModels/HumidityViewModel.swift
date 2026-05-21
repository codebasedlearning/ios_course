// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 HumidityViewModel consumes the AsyncStream exposed by HumiditySensor inside
 a long-running Task. This is the Swift Concurrency answer to "push me
 values over time".

 Why @MainActor here:
  - The class mutates 'currentHumidity', which drives SwiftUI.
  - Unlike the delegate-based HeartbeatViewModel, there is no synchronous
    protocol callback to keep nonisolated — we await values inside a Task,
    and we can simply hop to the main actor by isolating the whole class.
  - In Swift 6 strict concurrency, isolating the VM is the canonical solution.
 */
@MainActor
@Observable
class HumidityViewModel {
    var currentHumidity: Int? = nil

    private var sensor = ServiceLocator.shared.humiditySensor
    // A handle to the consumer Task so we can cancel it on stopMonitoring().
    // Cancelling the Task makes the 'for await' loop terminate cleanly.
    private var listenerTask: Task<Void, Never>?

    func startMonitoring() {
        // Cancel any previous listener — defensive in case startMonitoring()
        // is called twice without a stopMonitoring() in between.
        listenerTask?.cancel()

        // Fresh stream for this monitoring cycle. See HumiditySensor for why.
        let stream = sensor.makeHumidityStream()
        sensor.startMonitoring()

        listenerTask = Task { [weak self] in
            // Iterates until the stream finishes OR the Task is cancelled.
            // Either way, the loop exits cleanly — no manual unsubscribe.
            for await value in stream {
                self?.currentHumidity = value
            }
        }
    }

    func stopMonitoring() {
        sensor.stopMonitoring()
        listenerTask?.cancel()
        listenerTask = nil
        currentHumidity = nil
    }
}
