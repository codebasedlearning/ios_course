// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct PowerView: View {
    @Environment(PowerViewModel.self) private var powerViewModel

    @State private var isOn = false

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 5) {
            Text("Power: \(toValidUnitStr(powerViewModel.currentPower,"W"))")
                .font(.title2)
            Toggle("", isOn: $isOn)
                .onChange(of: isOn) {
                    if isOn { powerViewModel.startMonitoring() }
                    else { powerViewModel.stopMonitoring() }
                }
        }.padding(5)
    }
}
