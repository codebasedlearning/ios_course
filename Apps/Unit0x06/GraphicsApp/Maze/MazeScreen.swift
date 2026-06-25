// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import SpriteKit
import CblUI

struct MazeScreen: View {
    @State private var scene: MazeGameScene = MazeScreen.makeScene()
    @State private var resetID = UUID()

    static func makeScene() -> MazeGameScene {
        MazeGameScene(size: CGSize(width: 500, height: 1000))
    }

    var body: some View {
        CblScreen(title: "Maze", image: "harbor1") {
            GeometryReader { geo in
                VStack(spacing:0) {
                    Divider()
                    SpriteView(scene: scene)
                        .id(resetID)
                        .frame(width: geo.size.width*0.9, height: geo.size.height*0.7)
                        .border(Color.black)
                        .ignoresSafeArea()
                    Button("Restart Scene") {
                        scene = MazeScreen.makeScene()
                        resetID = UUID() // change the identifier to force-replace the scene
                    }
                }
            }
        }
    }
}

#Preview {
    MazeScreen()
}
