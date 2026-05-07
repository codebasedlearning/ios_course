// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

struct UserView: View {
    @Environment(UserViewModel.self) private var userViewModel

    var body: some View {
        ZStack {
            HStack(alignment: .lastTextBaseline, spacing: 5) {
                Text("User:")
                Text("\(userViewModel.user)").font(.title)
            }
            HStack {
                Spacer()
                Button("Login") { userViewModel.login() }
                .padding(3)
                .border(CblTheme.red, width: 1)
                .padding(5)
            }
        }.padding(5)
    }
}
