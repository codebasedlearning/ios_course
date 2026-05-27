// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

struct PostScreen: View {
    @Environment(OfflineViewModel.self) var offlineViewMode
    @Environment(PostViewModel.self) var postViewModel
    
    var body: some View {
        CblScreen(title: "Posts Screen", image: "lego_background") {
            VStack {
                HStack {
                    Text("State: \(offlineViewMode.currentState)")
                    Spacer()
                    Button("Off") { offlineViewMode.goOffline()}
                    Button("On") { offlineViewMode.goOnline()}
                    Button("Err") { offlineViewMode.goError()}
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
            .onChange(of: offlineViewMode.currentState) {
                postViewModel.fetchPosts()
            }
        }
    }
}

struct CommentsView: View {
    @Environment(OfflineViewModel.self) var offlineViewMode
    @Environment(CommentsViewModel.self) var viewModel

    var postId: Int

    var body: some View {
        VStack {
            Text(viewModel.isLoading ? "loading" : "done")
            List(viewModel.comments, id: \.id) { comment in
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
                viewModel.fetchComments(forPostId: postId)
            }
        }
        .background(Color.mint)
        .onChange(of: offlineViewMode.currentState) {
            viewModel.fetchComments(forPostId: postId)
        }
    }
}
