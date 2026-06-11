// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

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
 
    /*
     NEW: Async/await with Task
     
     Note:
      - SwiftUI's .onAppear and button actions are synchronous contexts. They
        can't directly call async functions.
      - 'fetchPosts' is a "fire-and-forget" operation:
          - it starts the work
          - updates state when done
          - doesn't return anything to the caller
          - SwiftUI observes the state changes automatically
      - Task { } is the bridge between synchronous and asynchronous worlds,
        it creates the async context
      - @MainActor guarantees main thread execution
     */
    func fetchPosts() {
        Task { @MainActor in
            posts = []
            isLoading = true
            
            let newPosts = await repository.fetchPosts()
            
            posts = newPosts
            isLoading = false
        }
    }
    
    /* OLD: Completion handler approach
    func fetchPosts() {
        posts = []
        isLoading = true
        repository.fetchPosts() { [weak self] newPosts in
            self?.isLoading = false
            self?.posts = newPosts
        }
    }
    */
}

class PostsRepository {
    
    // NEW: Async/await - returns value directly, no completion handler
    func fetchPosts() async -> [Post] {
        let manager = ServiceLocator.shared.offlineModeManager
 
        guard manager.isOnline, let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            return OfflineData.getPosts(state: manager.state)
        }

        print("start URLRequest Posts")
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5     // default 60
        
        do {
            // NEW: async/await URLSession API - no completion handler, no .resume() needed
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode([Post].self, from: data)
            return decodedResponse
            
        } catch {
            print("Network/decode error: \(error)")
            manager.goError()
            return OfflineData.getPosts(state: manager.state)
        }
    }
    
    /* OLD: Completion handler approach
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
    */
}
