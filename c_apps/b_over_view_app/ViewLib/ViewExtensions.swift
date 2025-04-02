// (C) 2024 A.Voß, a.voss@fh-aachen.de, ios@codebasedlearning.dev

import SwiftUI

extension View {
    var asLine: some View {
        self.frame(maxWidth: .infinity).background(.orange.opacity(0.8))
    }
}
