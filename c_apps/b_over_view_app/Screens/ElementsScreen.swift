// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct ElementsScreen: View {
    // this is not a good design, but why?
    // (that is enough for now, we will discuss this in the lecture on models and life cycles)
    @State var actionDelayWorkItem: DispatchWorkItem?
    @State private var lastAction = "-" {
        didSet {
            actionDelayWorkItem?.cancel()
            actionDelayWorkItem = DispatchWorkItem { lastAction = "-" }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: actionDelayWorkItem!)
            // this is also bad, why?
            // DispatchQueue.main.asyncAfter(deadline: .now() + 1) { lastAction = "-" }
        }
    }
    
    @State private var input = "-"
    @State private var isOn = false
// also not good... {
//        didSet { lastAction = "toggle" }
//    }
    
    @State private var value = 0.5
    @State private var quantity = 0
    @State private var selectedOption = "Beer"
    
    var body: some View {
        VStack(spacing: 5) {
            Divider()
            Text("– Action –").asLine
            Text("Action: \(lastAction)")
            
            Text("– Input –").asLine
            TextField("Enter your name", text: $input)
            
            Text("– Buttons –").asLine
            HStack {
                Button(action: {
                    lastAction = "Button 1 clicked"
                }) {
                    Text("Button 1")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                }
                Button(action: {
                    lastAction = "Button 2 clicked"
                }) {
                    Text("Button 2")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                Button("Button 3") {
                    lastAction = "Button 3 clicked"
                }
                .buttonStyle(CustomButtonStyle())
            }.padding()
            
            Text("– Toggle –").asLine
            Toggle("Enable Feature", isOn: $isOn)
                .onChange(of: isOn) { lastAction = "toggle" }
            
            Text("– Slider –").asLine
            Slider(value: $value, in: 0...1) { start in
                if !start {
                    lastAction = "slider \(value)"
                }
            }
            
            Text("– Stepper –").asLine
            Stepper {               // or Stepper("Quantity", value: $quantity, in: 0...10)
                Text("Quantity")
            } onIncrement: {
                lastAction = "quantity inc \(quantity)"
                quantity+=1
                                //incrementStep()
                             } onDecrement: {
                                 quantity-=1
                                 lastAction = "quantity dec \(quantity)"
                             }
            
            // or DatePicker
            Text("– Picker –").asLine
            Picker("Options", selection: $selectedOption) {
                Text("Beer").tag("Beer")
                Text("Juice").tag("Juice")
            }
            .onChange(of: selectedOption) { lastAction = "pick \(selectedOption)" }
            
            Picker("Options", selection: $selectedOption) {
                Text("Beer").tag("Beer")
                Text("Juice").tag("Juice")
            }
            .pickerStyle(SegmentedPickerStyle())
            Spacer()
        }.onDisappear {
            // this is a good place for...
            actionDelayWorkItem?.cancel()
            // print("end of view")
        }
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)
    }
}
