// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct CalculatorScreen: View {
    
    var body: some View {
        ZStack {
            Image("lego_class_background")
                .resizable()
                //.scaledToFill()
                .opacity(0.2)
                .ignoresSafeArea()
            VStack(spacing:0) {
                Divider()
                HeaderText(text: "Welcome Screen")
                    .padding(.bottom, 20)
                CalculatorView()
                Spacer()
            }
        }
    }
}

struct CalculatorView: View {
    @State private var display = "0.0"    // second op
    @State private var current = 0.0    // first op
    @State private var pendingOperation: String? = nil
    @State private var resetOnNextInput = false
    
    let buttons: [[String]] = [
        ["7", "8", "9", "+"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "×"],
        ["0", ".", "=", "÷"]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text(display)
                .font(.system(size: 64))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { label in
                        Button(action: { self.buttonTapped(label) }) {
                            Text(label)
                                .font(.title)
                                .frame(width: 70, height: 70)
                                .tint(Color.white)
                                .background(Color.blue.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            
            Button("Clear") {
                clear()
            }
            .padding()
        }
        .padding()
    }
    
    private func buttonTapped(_ label: String) {
        switch label {
        case "+", "-", "×", "÷":
            current = Double(display) ?? 0
            pendingOperation = label
            resetOnNextInput = true
            
        case "=":
            if let operation = pendingOperation, let input = Double(display) {
                switch operation {
                case "+": current += input
                case "-": current -= input
                case "×": current *= input
                case "÷": current /= input
                default: break
                }
                display = String(current)
                pendingOperation = nil
                resetOnNextInput = true
            }
            
        case ".":
            if !display.contains(".") {
                display += "."
            }
            
        default:
            if resetOnNextInput {
                display = label
                resetOnNextInput = false
            } else {
                display = (display == "0.0") ? label : display + label
            }
        }
    }
    
    private func clear() {
        display = "0.0"
        current = 0
        pendingOperation = nil
        resetOnNextInput = false
    }
}
