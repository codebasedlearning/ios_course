// (C) 2024 A.Voß, a.voss@fh-aachen.de, ios@codebasedlearning.dev

import SwiftUI


struct GesturesScreen: View {
    @State private var imageNames = [
        "pirates_lego_ship1",
        "pirates_lego_ship3",
        "pirates_lego_ship2"
    ]
    let scalingFactor = 0.8
    
    @State private var image1_selected = false
    @State private var image2_selected = false
    // @GestureState designed to handle temporary states that change during a gesture,
    // Once the gesture ends, the state automatically resets to its initial value
    @GestureState private var image2_pressing = false
    
    @GestureState private var rotationAngle: Angle = .zero
    @State private var rotation: Angle = .zero
    
    @GestureState private var magnification: CGFloat = 1.0
    @State private var zoom: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing:0) {
                Divider()
                HeaderText(text: "Gesture Sailing")
                    .padding(.bottom, 5)
                Image(imageNames[0])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .border(image1_selected ? Color.red : Color.clear, width: 5)
                    .padding(10)
                    .frame(width: geo.size.width * scalingFactor)
                // gestures
                    .onTapGesture { image1_selected.toggle() }
                // or via .gesture( DragGesture() ... .updating
                    .draggable("0") {
                        Image(systemName: "scope").font(.system(size: 50))
                    }
                Text("tap to select, or drag to ship")
                
                Image(imageNames[1])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .border(image2_selected ? Color.blue : Color.clear, width: 5)
                    .padding(10)
                    .frame(width: geo.size.width * scalingFactor)
                // effect
                    .opacity(image2_pressing ? 0.3 : 1.0)
                // drop target; or for DragGesture, use .onDrop(of: [Image.self],...
                    .dropDestination(for: String.self) { items, location in
                        // items[0] contains image, but we know that
                        imageNames.swapAt(1,0)
                        return true
                    }
                // gestures
                    .gesture(LongPressGesture(minimumDuration: 1.0)
                        .updating($image2_pressing) { value, state, transaction in
                            state = value
                            transaction.animation = Animation.easeInOut(duration: 1.5)
                        }.onEnded { value in
                            image2_selected.toggle()
                        })
                Text("long tap to select")
                
                Image(imageNames[2])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .border(image1_selected ? Color.red : Color.clear, width: 5)
                    .padding(10)
                    .frame(width: geo.size.width * scalingFactor)
                // effects
                    .rotationEffect(rotation + rotationAngle)
                    .scaleEffect(zoom * magnification)
                // drop target, again only image 0
                    .dropDestination(for: String.self) { items, location in
                        imageNames.swapAt(2,0)
                        return true
                    }
                // gestures
                    .gesture(TapGesture(count: 2)
                        .onEnded { rotation = .zero; zoom = 1.0 }
                    )
                // we can treat them individually, but then the first one wins
                    .gesture(
                        SimultaneousGesture(
                            RotateGesture()
                                .updating($rotationAngle) { value, state, transaction in
                                    state = value.rotation
                                }.onEnded { value in
                                    rotation = rotation + value.rotation
                                },
                            MagnificationGesture()
                                .updating($magnification) { value, state, transaction in
                                    state = value
                                }.onEnded { value in
                                    zoom = zoom * value
                                })
                    )
                Text("rotate and pinch, double tap to reset")
                
                Spacer()
            }
        }
    }
    
}

#Preview {
    GesturesScreen()
}
