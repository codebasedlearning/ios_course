// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

/*
 Screen now lives in this file. Apart from that, we see a @Binding binding to the selectedTab.
 */

import SwiftUI

struct PlayScreen: View {
    @Binding var selection: Int
    
    var body: some View {
        ZStack {
            Image("pirates_lego_ship1")
                .resizable()
                .scaledToFill()
                .opacity(0.6)
                .ignoresSafeArea()
            VStack {
                Button("What will we do with a drunken sailor?") {
                    selection = 1
                }
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
                    .padding(.all, 10)
            }
            .padding()
            .background(Color.mint.opacity(0.5))
            .cornerRadius(20)
        }
    }
}

