// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import Combine

/*
 PowerSensor is its own SensorDataReceiver and rebroadcasts new readings
 via a Combine PassthroughSubject. Subscribers attach with .sink() and
 receive type-safe Int values.

 Trade-offs of Combine as a notification mechanism:
   Feature                Combine (Publisher)
   Type safety            Yes
   Lifecycle management   Yes (via AnyCancellable)
   Global broadcast       Optional — you decide who gets the publisher
 */
class PowerSensor: SimulatedSensor, SensorDataReceiver {
    public let powerPublisher = PassthroughSubject<Int, Never>() // sends to all active subscribers

    init() {
        super.init(minValue: 0, maxValue: 500, startValue: 100, variation: 10)
        self.sensorDataReceiver = self
    }

    func didReceiveSensorData(_ data: Int) {
        powerPublisher.send(data)
    }
}
