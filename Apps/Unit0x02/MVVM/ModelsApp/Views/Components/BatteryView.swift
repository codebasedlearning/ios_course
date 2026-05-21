// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

/*
 BatteryView combines Toggle (user intent) with the modern .task(id:)
 modifier (resource hygiene + structured concurrency). This is the
 same idea as HumidityView, but done with one tool instead of three.

 How .task(id: isOn) works:
  - When the view first appears, the task body runs.
  - When 'isOn' changes, the previous task is *cancelled*, and the
    body runs again with the new value.
  - When the view disappears, the task is cancelled.

 The body checks isOn and either starts monitoring (and sleeps to keep
 the Task alive) or returns immediately. Either way, on cancellation,
 stopMonitoring() runs in the catch+continuation path.

 This is a one-liner replacement for the three callbacks in HumidityView
 (.onChange + .onAppear + .onDisappear). It's the most "Swift-Concurrency
 native" way to write this, and is preferable whenever the work is
 actually async or the VM offers an async entry point.
 */
struct BatteryView: View {
    @Environment(BatteryViewModel.self) private var batteryViewModel
    @State private var isOn = false

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 5) {
            Text("Battery: \(toValidUnitStr(batteryViewModel.currentBattery,"%"))")
                .font(.title2)
            Toggle("", isOn: $isOn)
        }
        .padding(5)
        // One modifier, both concerns: restarts on toggle change AND
        // cancels on view-disappear. Cleanup happens after Task.sleep
        // throws CancellationError.
        .task(id: isOn) {
            guard isOn else { return }
            batteryViewModel.startMonitoring()
            do {
                // Keep the Task alive until cancellation (toggle-off
                // or view-disappear). Modern Duration API.
                try await Task.sleep(for: .seconds(60 * 60 * 24 * 365))
            } catch {
                // Cancelled — fall through to cleanup.
            }
            batteryViewModel.stopMonitoring()
        }
    }
}
