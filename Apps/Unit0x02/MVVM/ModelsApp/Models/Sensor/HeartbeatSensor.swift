// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 HeartbeatSensor uses the most direct notification mechanism: the user of
 the sensor (e.g. a ViewModel) installs itself as the sensorDataReceiver
 and is called back directly via the SensorDataReceiver protocol.

 Limitation: only one receiver can be registered at a time. If you need
 multiple subscribers, see TemperatureSensor (NotificationCenter) or
 PowerSensor (Combine) for alternatives.

 Remember: in order to work with a HeartbeatSensor, you must provide
 a sensorDataReceiver.
 */
class HeartbeatSensor: SimulatedSensor {
    init() {
        super.init(minValue: 40, maxValue: 200, startValue: 60, variation: 2)
    }
}
