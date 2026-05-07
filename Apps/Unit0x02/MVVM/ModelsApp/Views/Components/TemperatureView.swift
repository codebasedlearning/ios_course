// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct TemperatureView: View {
    @Environment(TemperatureViewModel.self) private var temperatureViewModel

    @State private var isOn = false

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 5) {
            Text("Temperature: \(toValidUnitStr(temperatureViewModel.currentTemperature,"°C"))")
                .font(.title2)
            Toggle("", isOn: $isOn)
                .onChange(of: isOn) {
                    if isOn { temperatureViewModel.startMonitoring() }
                    else { temperatureViewModel.stopMonitoring() }
                }
        }.padding(5)
    }
}
