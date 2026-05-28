// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import Supabase
import Combine

fileprivate let logger = PredefinedLogger.dataLogger

struct ReadAllMessagesViewData: Decodable, Hashable, Identifiable {
    let id: UUID
    let createdAt: Date     // Supabase SDK decodes snake_case → camelCase automatically
    let email: String?
    let message: [String: String]?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case email
        case message
    }
}

struct GlobalMessageQueueInsertData: Encodable, Hashable {
    let userId: UUID        // Supabase SDK encodes camelCase → snake_case automatically
    let message: [String: String]

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case message
    }
}

@Observable
class MessagesViewModel {
    var messages: [ReadAllMessagesViewData] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Subscribe to realtime table-change signals from DatabaseConnector.
        // Debounce so a burst of rapid inserts only triggers one fetch.
        ServiceLocator.shared.databaseConnector.messagesChangedPublisher
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.fetchMessages()
            }
            .store(in: &cancellables)
    }

    func insertMessage(message: String) {
        Task {
            let connector = ServiceLocator.shared.databaseConnector          // our wrapper
            let supabase = ServiceLocator.shared.databaseConnector.supabaseClient  // Supabase SDK

            guard connector.isAuthenticated, let userId = connector.userProfile?.id else {
                logger.notice("[MessagesViewModel] insert not authenticated")
                return
            }

            let insertData = GlobalMessageQueueInsertData(userId: userId, message: ["command": "message", "payload": message])
            do {
                logger.notice("[MessagesViewModel] insert message:\(message)")
                try await supabase
                    .from("global_message_queue")
                    .insert(insertData)
                    .execute()
                logger.notice("[MessagesViewModel] insert worked")
                fetchMessages()
            } catch {
                logger.error("[MessagesViewModel] insert error:\(error)")
            }
        }
    }

    func fetchMessages() {
        Task {
            let supabase = ServiceLocator.shared.databaseConnector.supabaseClient

            do {
                logger.notice("[MessagesViewModel] fetch messages")
                messages = try await supabase
                    .from("read_all_messages")
                    .select("id, created_at, email, message")
                    .execute()
                    .value
                logger.notice("[MessagesViewModel] fetch messages worked")
            } catch {
                logger.error("[MessagesViewModel] fetch error:\(error)")  // was "insert error" — copy-paste bug
            }
        }
    }

}
