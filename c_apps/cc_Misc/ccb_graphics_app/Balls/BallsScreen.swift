// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import Combine

struct BallsScreen: View {
    @State var ballModel: BallModel = BallModel()
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing:0) {
                Divider()
                HeaderText(text: "Balls")
                    .padding(.bottom, 5)
                ZStack {
                    BallView(ball: ballModel)
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: ballModel.wallSize.width, height: ballModel.wallSize.height)
                        .position(ballModel.wallPosition)
                }
                //.edgesIgnoringSafeArea(.all)
                .background(Color.green)
                .frame(width: geo.size.width, height: geo.size.height*0.8)

                Divider()
                HStack {
                    Button(action: {
                        ballModel.startAnimation(size: CGSize(width:geo.size.width, height:geo.size.height*0.8), radius: 35)
                    }, label: {
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }).padding(5)
                    Button(action: {
                        ballModel.stopAnimation()
                    }, label: {
                        Image(systemName: "stop.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    })
                }.padding(5)
                Spacer()
            }
        }
    }
}

struct BallView: View {
    var ball: BallModel
    
    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 70, height: 70)
            .position(ball.position)
            .onTapGesture {
                ball.jump()
            }
    }
    
}

@Observable
class BallModel {
    var position = CGPoint(x: 100, y: 100)
    var velocity = CGPoint(x: 4, y: 4)
    var radius = 0.0
    
    private var timer: AnyCancellable?
    
    // Wall properties
    var wallPosition = CGPoint(x: 200, y: 300)
    var wallSize = CGSize(width: 200, height: 20)
    
    func startAnimation(size: CGSize, radius: Double) {
        position = CGPoint(x: 100, y: 100)
        velocity = CGPoint(x: 4, y: 4)
        self.radius = radius
        // repeat, runLoop
        timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.updatePosition(size)
        }
    }
    
    func stopAnimation() {
        timer?.cancel()
    }
    
    func jump() {
        velocity.y = -15
    }
    
    private func updatePosition(_ size: CGSize) {
        position.x += velocity.x
        position.y += velocity.y
        
        if position.x < 0 || position.x > size.width {  // UIScreen.main.bounds.width
            velocity.x = -velocity.x
        }
        
        if position.y < self.radius || position.y > size.height {
            velocity.y = -velocity.y
        }
        
        // Wall collision detection
        if position.x > wallPosition.x - wallSize.width / 2 &&
            position.x < wallPosition.x + wallSize.width / 2 &&
            position.y + 25 > wallPosition.y - wallSize.height / 2 &&
            position.y - 25 < wallPosition.y + wallSize.height / 2 {
            velocity.y = -velocity.y
        }
        
        // Gravity
        velocity.y += 0.8
    }
}

#Preview {
    BallsScreen()
}
