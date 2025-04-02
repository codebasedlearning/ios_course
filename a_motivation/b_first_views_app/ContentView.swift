// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

/*
 Not much new from a language point of view, just a few more 'Views'.
 
 The idea is to compose your final layout from simple, small and independent views, such as 'LegoBackground' or 'ButtonTextLine'. They can have parameters, of course.
 
 If you look closely, you can also see trailing lambdas in 'Button'.
 */

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LegoBackground()
            VStack(spacing: 10) {
                Text("Hello, iOS Course!")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                Divider()
                Image(systemName: "swift")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .padding(.vertical, 16)
                ButtonTextLine(remainingText: "Remaining Line")
            }
            .padding()
        }
    }
}

struct LegoBackground: View {
    var body: some View {
        Image("LegoClass")
            .resizable()
            .scaledToFill()
            .opacity(0.3)
            .edgesIgnoringSafeArea(.all)
            .offset(x: -90, y: 0)
    }
}

struct ButtonTextLine: View {
    let remainingText: String
    
    var body: some View {
        HStack {
            Button("Click-Me") {
                print("🔍 Button clicked at \(Date())")
            }
            Text(remainingText)
        }
    }
}
