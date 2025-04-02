// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

/*
 Here we use enums and observed properties.
 */

import Foundation
import Combine

enum Player: String {
    case x = "❌"
    case o = "⭕"
    case none = ""
}

@Observable
class GameViewModel {
    var currentPlayer: Player = .x
    var score = 0

    // don't modify attributes, make actions
    func makeTurn(inc: Int) {
        score += inc
        currentPlayer = (currentPlayer == .x) ? .o : .x
    }

    func reset() {
        currentPlayer = .x
    }
}
