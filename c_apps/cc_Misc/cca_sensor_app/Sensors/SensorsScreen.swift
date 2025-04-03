// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct SensorsScreen: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @State var sensorModel = SensorModel()
    @State private var rotation: Angle = .zero
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing:0) {
                Divider()
                HeaderText(text: "Sensors")
                    .padding(.bottom, 5)
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
                        rotation + Angle(degrees: -(sensorModel.accelerometerData?.acceleration.x ?? 0)*45.0)
                    )
                    .rotation3DEffect(
                        .degrees(sensorModel.accelerometerData?.acceleration.x ?? 0)*45.0,
                        axis: (x: 0, y: 1, z: 0)
                    )
                Spacer()
            }
        }
        .onChange(of: scenePhase) { oldState, newState in
            if newState == .active {
                sensorModel.startReadingSensors()
            } else {
                sensorModel.stopReadingSensors()
            }
        }
    }
}

#Preview {
    SensorsScreen()
}
