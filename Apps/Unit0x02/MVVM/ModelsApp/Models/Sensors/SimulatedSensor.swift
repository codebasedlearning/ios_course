// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 SimulatedSensor is the base class for all our 'sensors'. It produces a 1D
 reading that varies by a small amount on every tick of an internal Timer,
 staying inside [minValue, maxValue]. So the readings flicker but do not
 jump around wildly.

 Concrete sensors (HeartbeatSensor, TemperatureSensor, PowerSensor) inherit
 from this with different ranges and notification mechanisms.

 ---

 Should a sensor such as HeartbeatSensor inherit or embed SimulatedSensor?

 Prefer Composition if:
  - You need high flexibility in the behavior of your objects.
  - You wish to avoid deep inheritance hierarchies and tight coupling.
  - You want parts of your application to be developed, changed and extended
    independently.

 Prefer Inheritance if:
  - The subclasses are truly specializations of the parent class.
  - You are confident the base class implementation will not undergo significant
    changes that could affect subclasses.
  - You want to use polymorphic behavior that inheritance naturally supports.
 */

class SimulatedSensor: SensorProtocol {
    var lastSensorData: Int

    // 'weak' avoids the classic delegate retain cycle: the ServiceLocator strongly
    // retains the sensor, and the sensor would otherwise strongly retain the ViewModel
    // that registered as receiver. With 'weak' the receiver can be released independently
    // of the sensor.
    //
    // Swift uses Automatic Reference Counting (ARC) to manage memory. Under the Hood,
    // a weak reference
    // - does NOT increment the reference count
    // - doesn't prevent deallocation
    // - automatically becomes nil when the object is deallocated (hence optional)
    //
    weak var sensorDataReceiver: SensorDataReceiver?

    private let minValue: Int
    private let maxValue: Int
    private let variation: Int
    private let timeInterval: Double
    private var timer: Timer?

    init(minValue: Int, maxValue: Int, startValue: Int, variation: Int = 1, timeInterval: Double = 1.0) {
        self.lastSensorData = startValue
        self.minValue = minValue
        self.maxValue = maxValue
        self.variation = variation
        self.timeInterval = timeInterval
    }

    func startMonitoring() {
        guard timer == nil else { return }

        // send the last known data at start; that typically refreshes the UI with a valid value
        self.sensorDataReceiver?.didReceiveSensorData(self.lastSensorData)

        // set timer and send new sensor data periodically;
        // runs on the current thread's RunLoop - which in most cases is the main thread;
        //
        // weak self means:
        // - self could become nil if the object is deallocated
        // - guard let self = self creates a temporary strong reference for the closure's execution
        timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }   // sometimes also 'strongSelf'
            self.lastSensorData = self.lastSensorData.adjusted(
                within: self.minValue...self.maxValue,
                variation: self.variation
            )
            self.sensorDataReceiver?.didReceiveSensorData(self.lastSensorData)
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
}
