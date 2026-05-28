// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

struct AlternativeStatusScreen<Content: View>: View {
    let title: String
    let image: String?
    let content: Content
    
    @State private var showExtraInfo: Bool = false
    
    public init(title: String, image: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.image = image
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            CblFullScreenBackground(background: (color: CblTheme.dark, opacity: 0.5),
                                    image: (name: image, opacity: 0.2))
            VStack(spacing: 0) {
                ZStack {
                    AlternativeTitle(text: title, toggleTitle: $showExtraInfo)
                    HStack(spacing: 0) {
                        Spacer()
                        StatusView(showExtraInfo: $showExtraInfo)
                    }
                }
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct AlternativeTitle: View {
    @Environment(\.colorScheme) var colorScheme
    
    let text: String
    @Binding var toggleTitle: Bool

    public var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 1)
            Text(text)
                .font(.title2)
                .bold(true)
                .onTapGesture { self.toggleTitle.toggle() }
                .frame(maxWidth: .infinity)
                .foregroundColor(CblTheme.light)
                .padding(12)
                .background(CblTheme.red.opacity(0.8))
                .border(CblTheme.light, width: 1)
        }
    }
}

public struct StatusView: View {
    @Environment(NetworkViewModel.self) var networkViewModel
    @Environment(DatabaseConnectorViewModel.self) var connector

    @Binding var showExtraInfo: Bool

    public var body: some View {
        if showExtraInfo {
            VStack(alignment: .trailing, spacing:1) {
                Button(action: {
                    networkViewModel.reset()
                    showExtraInfo.toggle()
                }) { Label("Reset Network", systemImage: "arrow.counterclockwise") }
                Button(action: {
                    connector.signOut()
                    showExtraInfo.toggle()
                }) { Label("Database Sign Out", systemImage: "rectangle.portrait.and.arrow.forward") }
                Button(action: {
                    connector.lastInfo = ""
                    showExtraInfo.toggle()
                }) { Label("Clear", systemImage: "xmark.circle") }
            }.font(.caption2).foregroundColor(CblTheme.light)
            .padding(5)
        } else {
            VStack(alignment: .trailing, spacing:1) {
                Text("\(networkViewModel.isConnected ? "Online" : "Offline")")
                if connector.isAuthenticated {
                    Button(action: {
                        connector.signOut()
                    }) { Label("\(connector.userProfile?.displayname ?? "-")", systemImage: "rectangle.portrait.and.arrow.forward") }
                } else {
                    Text("Unauthenticated")
                }
                if connector.lastInfo.isEmpty {
                    Text("-")
                } else {
                    Text("→ \(connector.lastInfo)")
                }
            }.font(.caption2).foregroundColor(CblTheme.light)
                .padding(5)
        }
    }
}
