// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

/*
 SensorScreen composes the sensor-related component Views.

 Each row demonstrates a different Model→ViewModel notification channel:
   User           – @Observable on Model (AuthService), no sensor
   Secrets        – fan-out: a SECOND VM reading the same @Observable AuthService
                    (hides itself when no user is signed in)
   Heartbeat      – delegate / protocol callback
   Temperature    – NotificationCenter
   Power          – Combine PassthroughSubject (stateless)
   Humidity       – AsyncStream  (Swift Concurrency)
   Battery        – Combine CurrentValueSubject (stateful)
   HeartbeatCI    – constructor injection variant of Heartbeat

 Each component owns its own ViewModel binding via @Environment — except
 HeartbeatViewCI, which owns its own VM internally (composition root pattern).

 All rows share the same HStack + Toggle layout for visual consistency,
 but each demonstrates a different control pattern:

   Heartbeat / Temperature / Power → user-driven (Toggle controls start/stop)
   Humidity                        → lifecycle-driven (Toggle disabled, monitoring
                                     tied to .onAppear / .onDisappear)
   Battery                         → user-driven + lifecycle (Toggle + .task(id: isOn);
                                     restarts on toggle, cancels on disappear)
 */
struct SensorScreen: View {
    var body: some View {
        CblScreen(title: "Sensor Screen", image: "lego_background") {
            VStack(spacing: 0) {
                UserView()
                SecretsView()       // appears/disappears with the User row's login state
                HeartbeatView()
                TemperatureView()
                PowerView()
                HumidityView()
                BatteryView()
                HeartbeatViewCI()
                Spacer()
            }
        }
    }
}
