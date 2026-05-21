// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

// just a demo that you can also extend Int

extension Int {
    func clamped(to limits: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, limits.lowerBound), limits.upperBound)
    }

    func adjusted(within range: ClosedRange<Int>, variation: Int) -> Int {
        let offset = Int.random(in: -variation...variation)
        return (self + offset).clamped(to: range)
    }
}
