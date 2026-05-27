// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

struct SensorsScreen: View {
    /*
     Why use scenePhase?

     To respond to app lifecycle changes, like:
      - Saving data when the app goes to the background
      - Refreshing UI when the app becomes active
      - Pausing animations or tasks when the app loses focus
     */
    @Environment(\.scenePhase) private var scenePhase
    
    @State var sensorModel = SensorModel()

    var body: some View {
        CblScreen(title: "Sensors", image: "lego_background") {
            GeometryReader { geo in
                VStack(spacing:0) {
                    VStack {
                        Text("Accelerometer").bold()
                        if let data = sensorModel.accelerometerData {
                            Text("X: \(String(format: "%.3f", data.acceleration.x))")
                            Text("Y: \(String(format: "%.3f", data.acceleration.y))")
                            Text("Z: \(String(format: "%.3f", data.acceleration.z))")
                        } else {
                            Text("No data available")
                        }
                        Divider()
                        Text("Gyroscope").bold()
                        if let data = sensorModel.gyroData {
                            Text("X: \(String(format: "%.3f", data.rotationRate.x))")
                            Text("Y: \(String(format: "%.3f", data.rotationRate.y))")
                            Text("Z: \(String(format: "%.3f", data.rotationRate.z))")
                        } else {
                            Text("No data available")
                        }
                        Divider()
                    }
                    .padding()
                    Image("pirates_lego_ship1")
                        .resizable()
                        .padding(10)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width * 0.8)
                        .rotationEffect(
                            Angle(degrees: -(sensorModel.accelerometerData?.acceleration.x ?? 0)*45.0)
                        )
                        .rotation3DEffect(
                            .degrees(sensorModel.accelerometerData?.acceleration.x ?? 0)*45.0,
                            axis: (x: 0, y: 1, z: 0)
                        )
                    Spacer()
                }
            }
            // onAppear: scenePhase is already .active on first launch, so onChange alone
            // would miss the initial transition — we need both.
            .onAppear {
                sensorModel.startReadingSensors()
            }
            .onChange(of: scenePhase) { _, newState in
                if newState == .active {
                    sensorModel.startReadingSensors()
                } else {
                    sensorModel.stopReadingSensors()
                }
            }
        }
    }
}
