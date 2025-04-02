// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct LandingScreen: View {
    @Binding var selection: Int
    
    var body: some View {
        VStack(spacing:0) {
            Divider()
            HeaderText(text: "Board Games")
                .padding(.bottom, 20)
            
            GeometryReader { geometry in    // needed for the 70%-30% distribution
                VStack(spacing: 0) {
                    Image("memory_backgrd")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.7)
                        .clipped()
                    VStack {
                        Text("Welcome to the Board Game Collection!")
                            .font(.title2)
                            .padding()
                        Button("Start a new game") { selection = 1 }
                            .padding()
                    }
                    .frame(height: geometry.size.height * 0.3)
                    .background(Color.white.opacity(0.9))
                }
                .edgesIgnoringSafeArea(.top)
            }
            
            Spacer()
       }
    }
}
