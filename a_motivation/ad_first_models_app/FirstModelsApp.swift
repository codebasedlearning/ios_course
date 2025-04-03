// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

/*
 Apart from the private vars, the rest is the same as in FirstApp.
 */

import SwiftUI

@main
struct FirstModelsApp: App {
    @State private var highscore = HighscoreViewModel()
    @State private var game = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(highscore)
                .environment(game)
                .onAppear { }
        }
    }
}
