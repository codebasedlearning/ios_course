// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 A tiny, deterministic mock that lets us test or preview a ViewModel
 without spinning up a real Timer-driven SimulatedSensor.

 This is exactly the kind of substitution that constructor injection makes
 effortless — and that the ServiceLocator version makes painful (you'd have
 to swap out ServiceLocator.shared, which is global and shared with everything
 else).

 Lives under TestSupport/ so it's clear this is non-production scaffolding.
 In a multi-target project this folder would belong to the test target only;
 here we keep it in the main target so SwiftUI Previews can use it.
 */
final class MockHeartbeatSensor: SensorProtocol {
    var lastSensorData: Int
    weak var sensorDataReceiver: SensorDataReceiver?

    init(initialBPM: Int = 72) {
        self.lastSensorData = initialBPM
    }

    func startMonitoring() {
        // emit one fixed value, no timers, no randomness — perfect for tests
        sensorDataReceiver?.didReceiveSensorData(lastSensorData)
    }

    func stopMonitoring() { /* no-op */ }
}
