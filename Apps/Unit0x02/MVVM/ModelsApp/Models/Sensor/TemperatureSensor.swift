// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 TemperatureSensor is its own SensorDataReceiver and rebroadcasts new
 readings via NotificationCenter on a named channel.

 Trade-offs of NotificationCenter as a notification mechanism:
   Feature                NotificationCenter
   Type safety            No (object: Any?)
   Lifecycle management   No (can leak observers)
   Global broadcast       Yes — anyone can subscribe
 */
class TemperatureSensor: SimulatedSensor, SensorDataReceiver {
    static let notificationName = Notification.Name("newTemperatureDetected")

    init() {
        super.init(minValue: -10, maxValue: 60, startValue: 20, variation: 2)
        self.sensorDataReceiver = self
    }

    func didReceiveSensorData(_ data: Int) {
        NotificationCenter.default.post(name: TemperatureSensor.notificationName, object: data)
    }
}
