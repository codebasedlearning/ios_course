// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

@main
struct TicTacToeApp: App {
    @State private var highscore = HighscoreViewModel()
    @State private var board = TicTacToeViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(highscore)
                .environment(board)
                .onAppear { }
        }
        
    }
}
