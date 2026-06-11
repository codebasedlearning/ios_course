// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

struct PostScreen: View {
    @Environment(OfflineViewModel.self) var offlineViewModel
    @Environment(PostViewModel.self) var postViewModel
    
    var body: some View {
        CblScreen(title: "Posts Screen", image: "lego_background") {
            VStack {
                HStack {
                    Text("State: \(offlineViewModel.currentState.displayName)")
                    Spacer()
                    Button("Off") { offlineViewModel.goOffline()}
                    Button("On") { offlineViewModel.goOnline()}
                    Button("Err") { offlineViewModel.goError()}
                }.padding(10)

                /*
                 That is the core component: NavigationStack (Master) with NavigationLink (Detail).
                 NavigationView is deprecated since iOS 16 — NavigationStack is the replacement.
                 */

                NavigationStack {
                    List {
                        ForEach(postViewModel.posts, id: \.id) { post in
                            NavigationLink(destination: CommentsView(postId: post.id)) {
                                Text(post.title)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.mint.opacity(0.4))
                        }
                    }
                    .navigationTitle("Posts")
                    .scrollContentBackground(.hidden)
                    .background(Color.mint.opacity(0.6))
                    .onAppear {
                        postViewModel.fetchPosts()
                    }
                }
            }
            .onChange(of: offlineViewModel.currentState) {
                postViewModel.fetchPosts()
            }
        }
    }
}

struct CommentsView: View {
    @Environment(OfflineViewModel.self) var offlineViewMode
    @Environment(CommentsViewModel.self) var commentsViewModel

    var postId: Int

    var body: some View {
        VStack {
            Text(commentsViewModel.isLoading ? "loading" : "done")
            List(commentsViewModel.comments, id: \.id) { comment in
                VStack(alignment: .leading, spacing: 0) {
                    Text("(Id:\(comment.id), postId:\(comment.postId))")
                        .foregroundStyle(.gray)
                    Text(comment.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(comment.body)
                        .font(.subheadline)
                }.listRowBackground(Color.mint.opacity(0.4))
            }
            .padding()
            .navigationBarTitle("Comments")
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                commentsViewModel.fetchComments(forPostId: postId)
            }
        }
        .background(Color.mint)
        .onChange(of: offlineViewMode.currentState) {
            commentsViewModel.fetchComments(forPostId: postId)
        }
    }
}
