// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 HeartbeatViewModel installs itself as a SensorDataReceiver on the
 heartbeat sensor (fetched from the global ServiceLocator) and pushes
 new readings into its observable state (currentBPM).

 Only one receiver can be registered on a HeartbeatSensor at a time —
 if you need multiple, see Temperature/Power for alternatives.

 In Swift 6 with strict concurrency, ViewModels driving SwiftUI are typically
 annotated '@MainActor'. We skip it here because the VM conforms to the
 (non-isolated) SensorDataReceiver protocol — applying @MainActor would require
 also marking 'didReceiveSensorData' as 'nonisolated' and dispatching to MainActor inside.
 */

// @MainActor
@Observable
class HeartbeatViewModel: SensorDataReceiver {
    var currentBPM: Int? = nil // use optional to models the absence of a value (no sentinel value)

    private var sensor = ServiceLocator.shared.heartbeatSensor

    init() {
        sensor.sensorDataReceiver = self
    }

    func didReceiveSensorData(_ data: Int) {
        currentBPM = data
    }
    /*
     nonisolated func didReceiveSensorData(_ data: Int) {
        // NOT MainActor-isolated -  can be called synchronously from any thread
        // and can't access MainActor properties directly, so we despatch to MainActor
        // Must dispatch to MainActor:
        Task { @MainActor in
             self.currentBPM = data
        }
     }
     */

    func startMonitoring() {
        sensor.startMonitoring()
    }

    func stopMonitoring() {
        sensor.stopMonitoring()
        currentBPM = nil
    }
}
