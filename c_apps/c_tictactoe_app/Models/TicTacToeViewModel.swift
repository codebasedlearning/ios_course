// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import Combine

enum Player: String {
    case x = "❌"
    case o = "⭕"
    case none = ""
}

@Observable
class TicTacToeViewModel {
    var board: [Player] = Array(repeating: .none, count: 3*3)
    
    var currentPlayer: Player = .x

    func tap(at index: Int) {
        guard board[index] == .none else { return }

        board[index] = currentPlayer
        currentPlayer = (currentPlayer == .x) ? .o : .x
    }

    func reset() {
        board = Array(repeating: .none, count: 9)
        currentPlayer = .x
    }
}
