// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import _SpriteKit_SwiftUI

struct MazeScreen: View {
    var scene: GameScene {
        let scene = GameScene(size: CGSize(width: 500, height: 1000))
        //scene.size = CGSize(width: 500, height: 1000)
        //scene.scaleMode = .fill
        return scene
    }
    var body: some View {
        GeometryReader { geo in
            VStack(spacing:0) {
                Divider()
                HeaderText(text: "Maze")
                    .padding(.bottom, 5)
                SpriteView(scene: scene)
                    //.id(resetID)
                    .frame(width: geo.size.width*0.9, height: geo.size.height*0.7)
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                    .ignoresSafeArea()
                Button("Restart Scene") {
                  //  resetID = UUID() // Change the identifier to restart the scene
                }
            }
        }
    }
}

#Preview {
    MazeScreen()
}
