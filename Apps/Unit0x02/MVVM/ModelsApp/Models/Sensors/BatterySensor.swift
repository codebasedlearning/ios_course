// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import Combine

/*
 BatterySensor is its own SensorDataReceiver and rebroadcasts new readings
 via a Combine 'CurrentValueSubject<Int, Never>'.

 PassthroughSubject vs. CurrentValueSubject — what's the difference?

   PassthroughSubject<Int, Never>:
     - Holds NO state.
     - A subscriber that joins after a value was sent has missed it; it
       only sees values emitted *after* it subscribed.
     - Use when "events" matter and a missed one is fine
       (e.g., "user tapped the button").

   CurrentValueSubject<Int, Never>:
     - Holds the latest value as state.
     - A new subscriber immediately receives the current value at subscription
       time, then every subsequent value.
     - Use when "current state" matters and a UI binding should never see
       a brief "no data" period (e.g., "battery level is 87%").

 For sensor data that always has a meaningful "last reading", the stateful
 variant maps better to the UI's needs. PowerSensor uses the stateless
 PassthroughSubject; BatterySensor uses the stateful CurrentValueSubject.
 */
class BatterySensor: SimulatedSensor, SensorDataReceiver {
    // The initial value (100) is what every subscriber sees the moment it
    // subscribes — before any didReceiveSensorData call has fired.
    public let batterySubject = CurrentValueSubject<Int, Never>(100)

    init() {
        super.init(minValue: 0, maxValue: 100, startValue: 80, variation: 4)
        self.sensorDataReceiver = self
    }

    func didReceiveSensorData(_ data: Int) {
        // 'send' updates the stored value AND forwards it to all subscribers.
        // Reading 'batterySubject.value' afterwards returns 'data'.
        batterySubject.send(data)
    }
}
