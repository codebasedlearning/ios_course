// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

struct LoginScreen: View {
    @Environment(DatabaseConnectorViewModel.self) var connector
    
    // from a recently used list or similar maybe
    let signIns = [
        "alice@codebasedlearning.com",
        "bob@codebasedlearning.com",
    ]

    // selectedEmail drives both the picker and the text field directly —
    // no need for a separate @State var email that just mirrors it
    @State private var selectedEmail: String = ""
    @State private var password = ""

    var body: some View {
        AlternativeStatusScreen(title: "Login", image: "lego_background") {
            GeometryReader { geo in
                VStack(spacing: 10) {
                    Picker("recently used", selection: $selectedEmail) {
                        ForEach(signIns, id: \.self) { signIn in
                            Text(signIn).tag(signIn)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)

                    TextField("email", text: $selectedEmail)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)

                    SecureField("password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity)

                    Button(action: {
                        connector.signIn(email: selectedEmail, password: password)
                    }) {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 20)

                    Button(action: {
                        connector.broadcast(message: "Help! 🤷")
                    }) {
                        Text("Helpdesk")
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                // GeometryReader replaces the deprecated UIScreen.main.bounds.width
                .frame(width: geo.size.width * 0.8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(CblTheme.dark, lineWidth: 2)
                )
                .frame(width: geo.size.width, height: geo.size.height) // centre in geo
            }
            .onAppear {
                if selectedEmail.isEmpty {
                    selectedEmail = signIns[0]
                }
            }
        }
    }
}
