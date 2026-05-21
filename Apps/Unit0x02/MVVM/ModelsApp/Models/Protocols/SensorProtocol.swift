// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

/*
 Two protocols form the data-side contract of the sensor subsystem:

  - SensorProtocol describes anything that can act as a sensor: it has a
    last-known reading, a single optional receiver, and start/stop methods.

  - SensorDataReceiver describes anything that wants to be told about new
    readings — typically a ViewModel.

 AnyObject constrains conformers to reference types wanted for two reasons:
   - it lets us mark the back-reference 'weak' (only class types can be weak),
   - delegates conceptually have identity — a struct delegate would be copied.
 */

protocol SensorDataReceiver: AnyObject {
    func didReceiveSensorData(_ data: Int)
}

protocol SensorProtocol: AnyObject {
    var lastSensorData: Int { get set }
    var sensorDataReceiver: SensorDataReceiver? { get set }

    func startMonitoring()
    func stopMonitoring()
}
