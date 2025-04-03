// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import Combine

@Observable
class HighscoreViewModel {
    
    // score should only increase
    private var _score: Int = 0     // backing field for score
    var score: Int {
        get { _score }
        set { if newValue == 0 || newValue > _score { _score = newValue; saveScore() } }
    }

    init() {
        score = loadScore()
    }
    
    func reset() {
        score = 0
    }
        
    private static let scoreKey = "userScoreKey"

    private func loadScore() -> Int {
        return UserDefaults.standard.integer(forKey: HighscoreViewModel.scoreKey)
    }

    private func saveScore() {
        UserDefaults.standard.set(score, forKey: HighscoreViewModel.scoreKey)
    }
}
