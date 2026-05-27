// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import Foundation

// data model — use let: API responses are immutable DTOs, they should not be mutated client-side
struct Post: Codable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

@Observable
class PostViewModel {
    var posts: [Post] = []
    var isLoading = false

    private var repository = ServiceLocator.shared.postsRepository
 
    func fetchPosts() {
        posts = []
        isLoading = true
        repository.fetchPosts() { [weak self] newPosts in
            self?.isLoading = false
            self?.posts = newPosts
        }
    }
}

class PostsRepository {
    func fetchPosts(completion: @escaping ([Post]) -> Void) {
        let manager = ServiceLocator.shared.offlineModeManager
 
        guard manager.isOnline, let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            completion(OfflineData.getPosts(state: manager.state))
            return
        }

        // make an asynchronous network request — typically to download data from a URL;
        // code gets called when the request finishes
        // https://developer.apple.com/documentation/foundation/url-loading-system

        print("start URLRequest Posts")
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5     // default 60
        
        // or dataTask(with: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode([Post].self, from: data)
                        completion(decodedResponse)
                        return
                    } catch {
                        print("JSON decode error: \(error)")
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
                manager.goError()
                completion(OfflineData.getPosts(state: manager.state))
            }
        }.resume()
        // the task is created but not started — you must call .resume() to kick it into gear;
        // forgetting that is the async equivalent of leaving your toast in the toaster
    }
}
