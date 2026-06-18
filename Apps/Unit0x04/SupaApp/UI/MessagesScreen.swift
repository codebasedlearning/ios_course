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
                        
                        // channelName comes straight off ReadAllMessagesViewData — either
                        // the read_all_messages view's joined column (server fetch) or
                        // LocalMessage.channel?.name via the SwiftData relationship
                        // (local-first echo); see MessagesViewModel for both paths.
                        Text("(\(message.email?.displayname ?? "-"))  #\(message.channelName ?? "-")")
                            .font(.footnote)
                    }
                }
                HStack {
                    TextField("Msg", text: $msg)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                    Button("Send") {
                        messagesViewModel.insertMessage(message: msg)
                        if messagesViewModel.lastError == nil { msg = "" }
                    } // .disabled(!connectorViewModel.isAuthenticated) // offline-mode
                    Button("BC") {
                        connectorViewModel.broadcast(message: msg)
                    }.padding()
                    // Manual trigger for syncNow() — push pending channels/messages,
                    // pull + merge the server's view, then prune local .synced rows
                    // the server no longer has. Everything except the prune step
                    // already runs automatically on its own trigger (reconnect,
                    // after composing, Realtime); this button just forces the full
                    // pipeline to run on demand, in order, right now — handy after
                    // editing the Supabase schema by hand, or just to watch it work.
                    // async work from a synchronous Button action needs its own Task.
                    Button("Sync") {
                        Task {
                            await messagesViewModel.syncNow()
                        }
                    }.padding()

                }.padding(.bottom,10)
                if let error = messagesViewModel.lastError {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.bottom, 4)
                }
                Divider()
            }
            .onAppear {
                messagesViewModel.fetchMessages()
            }
        }
    }
}
