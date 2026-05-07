// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 For (observed) ViewModels we use .environment with @Environment. But what
 if you need a global service such as a data repository? You can go with DI
 or with a global ServiceLocator.

 Note: ServiceLocator is sometimes called an "anti-pattern" because dependencies
 become invisible — any class can reach in and grab a sensor without declaring
 that it needs one. This makes unit-testing harder (you have to swap globals)
 and hides coupling.

 One alternative is constructor injection (pass a SensorProtocol into the
 ViewModel), shown in the Heartbeat-related-CI codes.
 We use ServiceLocator here because it keeps the demo small and lets the
 focus stay on MVVM itself.
 */
class ServiceLocator {
    static let shared = ServiceLocator()    // this is the singleton

    private lazy var heartbeatSensorInstance = HeartbeatSensor()
    private lazy var temperatureSensorInstance = TemperatureSensor()
    private lazy var powerSensorInstance = PowerSensor()

    var heartbeatSensor: HeartbeatSensor { heartbeatSensorInstance }     // remember: a getter
    var temperatureSensor: TemperatureSensor { temperatureSensorInstance }
    var powerSensor: PowerSensor { powerSensorInstance }
}
