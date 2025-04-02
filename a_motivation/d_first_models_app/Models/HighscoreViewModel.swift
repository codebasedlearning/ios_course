// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

/*
 Not so much from the language point of view, only a class with properties and a backing field.
 */

import Foundation
import Combine

/*
 An observable (view)model, using UserDefaults for storage.
 
 Try to limit the interface to useful operations, rather than providing
 blind getters and setters that turn it into a dumb data-holder.
*/

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
