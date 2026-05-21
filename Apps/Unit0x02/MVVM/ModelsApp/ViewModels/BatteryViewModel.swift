// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import Combine

/*
 BatteryViewModel subscribes to a Combine CurrentValueSubject.

 Notice the subtle behavioural difference compared with PowerViewModel
 (PassthroughSubject):
  - 'currentBattery' is set immediately on init, because CurrentValueSubject
    delivers its stored value at subscription time. So 'currentBattery' is
    typed Int? but practically never observed as nil unless we deliberately
    clear it on stopMonitoring().
  - The View can therefore safely show a value even before the user has
    triggered any monitoring.
 */
@Observable
class BatteryViewModel {
    var currentBattery: Int? = nil

    private var cancellables = Set<AnyCancellable>()
    private var sensor = ServiceLocator.shared.batterySensor

    init() {
        sensor.batterySubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in self?.currentBattery = value }
            .store(in: &cancellables)
    }

    func startMonitoring() {
        sensor.startMonitoring()
    }

    func stopMonitoring() {
        sensor.stopMonitoring()
        // We intentionally clear the value here to make the "off" state
        // visible in the UI. Without this line the last reading would
        // remain on screen — which is sometimes exactly what you want for
        // a battery indicator (it would mirror the OS battery icon).
        currentBattery = nil
    }
}
