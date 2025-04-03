// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct HeaderText: View {
    let text: String
    var opacity = 0.8
    var body: some View {
        Text(text)
            .font(.title2)
            .frame(maxWidth: .infinity)
            .background(.orange.opacity(opacity))
    }
}
