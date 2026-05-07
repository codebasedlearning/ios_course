// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

/*
 SensorScreen composes the four sensor-related component Views (User,
 Heartbeat, Temperature, Power) plus the constructor-injection variant
 HeartbeatViewCI. Each component owns its own ViewModel binding via
 @Environment — except HeartbeatViewCI, which owns its own VM internally.
 */
struct SensorScreen: View {
    var body: some View {
        CblScreen(title: "Sensor Screen", image: "lego_background") {
            VStack(spacing: 0) {
                UserView()
                HeartbeatView()
                TemperatureView()
                PowerView()
                HeartbeatViewCI()
                Spacer()
            }
        }
    }
}
