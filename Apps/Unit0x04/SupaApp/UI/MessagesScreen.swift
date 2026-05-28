// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

struct MessagesScreen: View {
    @Environment(MessagesViewModel.self) var messagesViewModel
    @Environment(DatabaseConnectorViewModel.self) var connectorViewModel
    
    @State private var msg = ""
    
    var body: some View {
        AlternativeStatusScreen(title: "Messages", image: "lego_background") {
            VStack {
                List(messagesViewModel.messages) { message in
                    VStack(alignment: .leading) {
                        if let msg = message.message, let payload=msg["payload"] {
                            Text("\(payload)")
                                .font(.headline)
                        } else {
                            Text("-")
                        }
                        
                        Text("(\(message.email?.displayname ?? "-"))")
                            .font(.footnote)
                    }
                }
                HStack {
                    TextField("Msg", text: $msg)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                    Button("Send") {
                        messagesViewModel.insertMessage(message: msg)
                    }.disabled(!connectorViewModel.isAuthenticated)
                    Button("BC") {
                        connectorViewModel.broadcast(message: msg)
                    }.padding()
                            
                }.padding(.bottom,10)
                Divider()
            }
            .onAppear {
                messagesViewModel.fetchMessages()
            }
        }
    }
}
