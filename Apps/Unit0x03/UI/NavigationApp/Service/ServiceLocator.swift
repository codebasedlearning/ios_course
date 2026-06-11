// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

class ServiceLocator {
    static let shared = ServiceLocator()
    
    private lazy var _offlineModeManager = OfflineModeManager()
    private lazy var _commentsRepository = CommentsRepository()
    private lazy var _postsRepository = PostsRepository()

    var offlineModeManager: OfflineModeManager { _offlineModeManager }
    var commentsRepository: CommentsRepository { _commentsRepository }
    var postsRepository: PostsRepository { _postsRepository }
}
