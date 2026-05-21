// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

/*
 HumidityView keeps the same HStack + Toggle layout as the other sensor
 rows so the screen stays visually consistent, but here the Toggle is
 *disabled* — kept only as a visual placeholder for layout symmetry.
 Monitoring is driven purely by the view lifecycle:

   .onAppear  → startMonitoring()
   .onDisappear → stopMonitoring()

 This contrasts with Heartbeat / Temperature / Power, where the Toggle
 expresses user intent. The pedagogical point: lifecycle wiring and
 user-driven wiring are independent choices — and you don't *have* to
 give the user a switch for every long-running operation.

 Note: startMonitoring() on the VM is idempotent (it cancels any
 previous listener before starting a new one), so the duplicate-start
 case "switch tabs and come back" is safe.
 */
struct HumidityView: View {
    @Environment(HumidityViewModel.self) private var humidityViewModel

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 5) {
            Text("Humidity: \(toValidUnitStr(humidityViewModel.currentHumidity,"%"))")
                .font(.title2)
            // Disabled Toggle — purely a layout placeholder. .constant
            // gives us a non-mutable binding without needing @State.
            Toggle("", isOn: .constant(true))
                .disabled(true)
        }
        .padding(5)
        // Pure lifecycle wiring. No user-intent gate.
        .onAppear  { humidityViewModel.startMonitoring() }
        .onDisappear { humidityViewModel.stopMonitoring() }
    }
}
