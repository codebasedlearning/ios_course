// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import Combine

/*
 TemperatureViewModel subscribes to NotificationCenter on the named
 channel published by TemperatureSensor. Type filtering happens via
 'compactMap { $0.object as? Int }', so anything that isn't an Int
 is silently dropped.
 */
@Observable
class TemperatureViewModel {
    var currentTemperature: Int? = nil  // again optional

    // same idea as in PowerViewModel
    private var cancellables = Set<AnyCancellable>()
    private var sensor = ServiceLocator.shared.temperatureSensor

    init() {
        NotificationCenter.default.publisher(for: TemperatureSensor.notificationName)
            .compactMap { $0.object as? Int }   // data could be anything, compactMap filters out nils
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newT in self?.currentTemperature = newT }
            .store(in: &cancellables)
    }

    func startMonitoring() {
        sensor.startMonitoring()
    }

    func stopMonitoring() {
        sensor.stopMonitoring()
        currentTemperature = nil
    }
}
