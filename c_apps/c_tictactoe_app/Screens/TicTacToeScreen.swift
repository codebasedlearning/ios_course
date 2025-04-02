// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct TicTacToeScreen: View {
    @Environment(TicTacToeViewModel.self) private var game
    @Environment(HighscoreViewModel.self) private var highscore
    
    var body: some View {
        ZStack {
            Image("street_board_game")
                .resizable()
                .scaledToFill()
                .opacity(0.6)
                .ignoresSafeArea()
            VStack(spacing:0) {
                Divider()
                HeaderText(text: "Tic Tac Toe")
                    .padding(.bottom, 20)
                
                HighscoreView()
                TicTacToeView()

                Button("Reset") { game.reset(); highscore.reset() }
                    .bold()
                    .foregroundColor(.black)
                    .padding(.all, 20)
                    .background(Color.orange.opacity(0.6))
                    .cornerRadius(20)
                Spacer()
            }
        }
    }
}

struct HighscoreView: View {
    @Environment(HighscoreViewModel.self) private var highscore

    var body: some View {
        ZStack {
            Text("Player [\(highscore.score)]")
                .font(.title3)
                .foregroundColor(.orange)
            HStack(spacing: 5) {
                Spacer()
            }
        }
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(.black.opacity(0.5))
    }
}

struct TicTacToeView: View {
    @Environment(TicTacToeViewModel.self) private var game
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<9, id: \.self) { index in
                ZStack {
                    Rectangle()
                        .foregroundColor(.mint.opacity(0.8))
                        .frame(height: 120)
                        .cornerRadius(8)
                    Text(game.board[index].rawValue)
                        .font(.system(size: 40))
                }
                .onTapGesture {
                    game.tap(at: index)
                }
            }
        }
        .padding()
    }
}
