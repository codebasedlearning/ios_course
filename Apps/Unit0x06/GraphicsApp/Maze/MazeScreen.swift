// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import Charts
import CblUI
import _SpriteKit_SwiftUI

struct MazeScreen: View {
    var scene: MazeGameScene {
        let scene = MazeGameScene(size: CGSize(width: 500, height: 1000))
        //scene.size = CGSize(width: 500, height: 1000)
        //scene.scaleMode = .fill
        return scene
    }

    var body: some View {
        CblScreen(title: "Maze", image: "lego_background") {
            GeometryReader { geo in
                VStack(spacing:0) {
                    Divider()
                    SpriteView(scene: scene)
                        //.id(resetID)
                        .frame(width: geo.size.width*0.9, height: geo.size.height*0.7)
                        .border(Color.black)
                        .ignoresSafeArea()
                    Button("Restart Scene") {
                      //  resetID = UUID() // Change the identifier to restart the scene
                    }
                }
            }
        }
    }
}
