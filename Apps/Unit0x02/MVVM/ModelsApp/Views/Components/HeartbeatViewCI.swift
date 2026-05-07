// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

/*
 HeartbeatViewCI — the call site for constructor injection.
 Two halves of DI via constructor:
  - Declaration (in HeartbeatViewModelCI.swift):
          init(sensor: SensorProtocol) { ... }
  - Composition (here):
          HeartbeatViewModelCI(sensor: HeartbeatSensor())

 The place where you actually wire concrete implementations to abstract
 dependencies is called the 'composition root'. In a small app, that's
 typically the @main App struct. For a single screen/component, like here,
 the owning View is the composition root for that subtree.
 */

struct HeartbeatViewCI: View {
    @State private var vm: HeartbeatViewModelCI
    @State private var isOn = false

    // Default argument = production wiring. Tests/previews can pass a mock
    // without the View having to know the difference.
    init(vm: HeartbeatViewModelCI = HeartbeatViewModelCI(sensor: HeartbeatSensor())) {  // [DI] composition root for production
        _vm = State(wrappedValue: vm)
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 5) {
            Text("Heartb.CI: \(toValidUnitStr(vm.currentBPM,"bpm"))")
                .font(.title2)
            Toggle("", isOn: $isOn)
                .onChange(of: isOn) {
                    if isOn { vm.startMonitoring() } else { vm.stopMonitoring() }
                }
        }.padding(5)
    }
}

// Live preview: real sensor (random walk, timer-driven).
#Preview("Live sensor") {
    HeartbeatViewCI()    // [DI] uses default = HeartbeatSensor()
}

// Mock preview: deterministic 72 BPM, no timers — same View, swapped dependency.
#Preview("Mock sensor (72 BPM)") {
    HeartbeatViewCI(
        vm: HeartbeatViewModelCI(sensor: MockHeartbeatSensor(initialBPM: 72))   // [DI] override for preview
    )
}
