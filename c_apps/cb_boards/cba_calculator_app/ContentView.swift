//
//  ContentView.swift
//  c_calculator_app
//
//  Created by Alexander Voss on 02.04.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CalculatorView()
    }
}

struct CalculatorView: View {
    @State private var display = "0"
    @State private var current = 0.0
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
                                .background(Color.gray.opacity(0.2))
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
                display = (display == "0") ? label : display + label
            }
        }
    }

    private func clear() {
        display = "0"
        current = 0
        pendingOperation = nil
        resetOnNextInput = false
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}
