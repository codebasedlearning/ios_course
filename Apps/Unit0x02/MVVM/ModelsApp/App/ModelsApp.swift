// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

@main
struct ModelsApp: App {
    // @State creates observable storage for view models that persists across view
    // updates. These instances are shared app-wide via SwiftUI's environment system.
    
    @State private var userViewModel = UserViewModel()
    @State private var heartbeatViewModel = HeartbeatViewModel()
    @State private var temperatureViewModel = TemperatureViewModel()
    @State private var powerViewModel = PowerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(userViewModel)
                .environment(heartbeatViewModel)
                .environment(temperatureViewModel)
                .environment(powerViewModel)
        }
    }
}
