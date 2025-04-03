// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

/*
 Not so much from the language point of view. Note that we can use the model via @Environment wherever we need it.
 */

import SwiftUI

struct LandingScreen: View {
    var body: some View {
        VStack(spacing:0) {
            Divider()
            HeaderText(text: "Board Games")
                .padding(.bottom, 20)
            ScoreView()
                .padding(.bottom, 20)
            Image("memory_backgrd")
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .clipped()
            Text("Welcome to my Board Game!")
                .font(.title2)
                .padding()
            GameView()
            Spacer()
       }
    }
}

struct ScoreView: View {
    @Environment(HighscoreViewModel.self) private var highscore
    @Environment(GameViewModel.self) private var game

    var body: some View {
        Text("Player: \(game.currentPlayer) | Score: \(game.score) | Highscore: \(highscore.score)")
            .font(.title3)
            .foregroundColor(.orange)
            .frame(maxWidth: .infinity)
        .background(.black.opacity(0.5))
        
    }
}

struct GameView: View {
    @Environment(HighscoreViewModel.self) private var highscore
    @Environment(GameViewModel.self) private var game
    
    var body: some View {
        HStack {
            Text("Change Score")
                .padding(.trailing, 10)
            Button("-") {
                game.makeTurn(inc: -1)
            }
            Button("+") {
                game.makeTurn(inc: +1)
                if game.score > highscore.score {
                    highscore.score = game.score
                }
            }
            Button("Reset") {
                game.reset()
                highscore.reset()
            }
        }
    }
}
