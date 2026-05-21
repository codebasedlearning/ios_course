// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

/*
 UserView shows the currently signed-in user (or "(not signed in)")
 and a Login button that rotates to a different candidate via
 AuthService.

 Note that the View pulls everything it needs from the VM's pre-
 formatted accessors:
   - displayName  → handles the "no user" case so the View doesn't
                    have to write 'currentUser?.name ?? "…"' inline
   - isSignedIn   → drives the button label

 The button always calls login() — when signed-in this rotates to a
 different candidate, when signed-out it picks one. Same one method,
 different effect depending on state.
 */
struct UserView: View {
    @Environment(UserViewModel.self) private var userViewModel

    var body: some View {
        ZStack {
            HStack(alignment: .lastTextBaseline, spacing: 5) {
                Text("User:")
                Text(userViewModel.displayName).font(.title)
            }
            HStack {
                Spacer()
                Button(userViewModel.isSignedIn ? "Switch" : "Login") {
                    userViewModel.login()
                }
                .padding(3)
                .border(CblTheme.red, width: 1)
                if (userViewModel.isSignedIn) {
                    Button("Logout") {
                        userViewModel.logout()
                    }
                        .padding(3)
                        .border(CblTheme.red, width: 1)
                }
            }
        }.padding(5)
    }
}
