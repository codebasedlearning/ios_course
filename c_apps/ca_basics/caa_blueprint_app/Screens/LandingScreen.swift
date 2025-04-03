// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct LandingScreen: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        ZStack {
            Image("lego_background")
                .resizable()
                //.scaledToFill()
                .opacity(0.2)
                .ignoresSafeArea()
            VStack(spacing:0) {
                Divider()
                HeaderText(text: "Welcome Screen")
                    .padding(.bottom, 20)
                Text("Score: \(appViewModel.score)")
                    .font(.title3)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .background(.black.opacity(0.5))
                Spacer()
            }
        }
    }
}
