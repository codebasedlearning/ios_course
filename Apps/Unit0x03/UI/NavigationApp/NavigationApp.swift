// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

@main
struct NavigationApp: App {
    @State private var offlineViewMode = OfflineViewModel()
    @State private var postViewModel = PostViewModel()
    @State private var commentsViewModel = CommentsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(offlineViewMode)
                .environment(commentsViewModel)
                .environment(postViewModel)
        }
    }
}
