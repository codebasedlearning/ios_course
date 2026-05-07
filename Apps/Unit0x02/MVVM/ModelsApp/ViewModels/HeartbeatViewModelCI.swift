// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 HeartbeatViewModelCI (CI=Constructor Injection).

 Same ViewModel as HeartbeatViewModel, but the dependency on the sensor
 is injected through the initializer instead of being fetched from the
 global ServiceLocator. This changes in practice:
 - The dependency is *visible* in the type's signature. Whoever creates a
   HeartbeatViewModelCI must supply a sensor — the compiler enforces it.
 - The sensor is typed as the protocol, not the concrete class. Anything
   that conforms to SensorProtocol works, including mocks for tests.
 - No singleton, no global state. Two views can hold two ViewModels with
   two different sensors without any rewiring.
 */
@Observable
class HeartbeatViewModelCI: SensorDataReceiver {
    var currentBPM: Int? = nil

    // 'let' (not 'var') — the dependency is fixed after init. Typed as the
    // protocol so the concrete implementation is interchangeable (see also SOLID).
    private let sensor: SensorProtocol

    init(sensor: SensorProtocol) {
        self.sensor = sensor
        self.sensor.sensorDataReceiver = self
    }

    func didReceiveSensorData(_ data: Int) {
        currentBPM = data
    }

    func startMonitoring() {
        sensor.startMonitoring()
    }

    func stopMonitoring() {
        sensor.stopMonitoring()
        currentBPM = nil
    }
}
