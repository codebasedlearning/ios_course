// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct ImagesScreen: View {
    @State private var dragAmount = CGSize.zero
    
    var body: some View {
        ZStack {
            HomeBackground()
            VStack(spacing: 5) {
                Divider()
                Text("– Original –").asLine
                Image("LegoImage")     // from xcassets
                
                Text("– Resized –").asLine
                HStack {
                    Spacer()
                    Image("LegoImage")
                        .resizable()
                        .frame(width: 120, height: 80)
                    Spacer()
                    Image("LegoImage")
                        .resizable()
                        .frame(height: 80)
                    Spacer()
                }
                
                Text("– Keep aspect ratio, clipped –").asLine
                HStack {
                    Spacer()
                    Image("LegoImage")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 80)
                        .clipped()
                    Spacer()
                    Image("LegoImage")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 80)
                        .offset(y: 15) // x: 20,
                        .clipped()
                    Spacer()
                }
                
                Text("– Real –").asLine
                HStack {
                    Spacer()
                    Image("LegoImage")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 80)
                        .offset(x: dragAmount.width, y: dragAmount.height+15)
                        .gesture(
                            DragGesture()
                                .onChanged { drag in
                                    self.dragAmount = drag.translation
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        self.dragAmount = .zero
                                    }
                                }
                        )
                        .clipped()
                        .border(Color.orange, width: 2)
                        .shadow(radius: 10)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct HomeBackground: View {
    var body: some View {
        ZStack {
            Color.indigo.opacity(0.5)
                .edgesIgnoringSafeArea(.all)    // .top .bottom
            GeometryReader { geo in             // we need the real size
                Image("Background")             // from xcassets
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    // .clipped()
                    .opacity(0.1)               // combines indigo with image
                    .edgesIgnoringSafeArea(.all)
                    .offset(x: 0, y: 0)
            }
        }
    }
}
