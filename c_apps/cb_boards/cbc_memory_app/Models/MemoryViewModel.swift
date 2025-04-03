// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import Combine

@Observable
class MemoryViewModel {
    var score = 0
    var cards: [Card] = []
}


struct Card {
    let emoji: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

