//
//  Project.swift
//  ios_course
//
//  Created by Alexander Voss on 11.05.25.
//

import SwiftUI
import Supabase

/*
 
 
fileprivate let logger = PredefinedLogger.dataLogger

struct ProjectData: Decodable, Identifiable {
    let id: Int
    let name: String
    let description: String
}

/*
    Project         Jenga   TicTacToe   Patience    D&D
    UserAlice         X                              X
    UserBob           X         X                    X
    UserCharly        X         X                    X
    UserDora                                X        X
 
 */

@Observable
class ProjectViewModel {
    var projects: [ProjectData] = []
    
    init() {}
    
//    func fetchProjects() {
//        Task {
//            logger.notice("[UserViewModel] fetch users")
//            users = [
//                UserData(id: 1, name: "Admin", email: "useradmin@codebasedlearning.com"),
//                UserData(id: 2, name: "Alice", email: "useralice@codebasedlearning.com"),
//                UserData(id: 3, name: "Bob", email: "userbob@codebasedlearning.com"),
//                UserData(id: 4, name: "Charly", email: "usercharly@codebasedlearning.com"),
//                UserData(id: 5, name: "Dora", email: "userdora@codebasedlearning.com"),
//            ]
//        }
//    }
    private var connector = ServiceLocator.shared.databaseConnector.current

    struct JoinProjectData: Decodable, Identifiable {
        let id: Int
        let profile_id: UUID
        let project_id: Int
        let name: String
        let description: String
    }

    func fetchProjects() {
        //let table = connector.client.from("project")
        Task {
            let profileId = connector.auth.currentUser!.id //  "current-user-uuid"
            let xprojects:[JoinProjectData] = try await connector
                            .from("profile_project_view")
                            .select()
                            .eq("profile_id", value: profileId)
                            .execute()
                            .value

//            projects = try await connector
//                .from("profile_project_links")
//                .select("projects(*)")
//                .eq("profile_id", value: profileId)
//                .execute().value
            
//            projects = try await connector
//                .from("projects")
//                .select()
//                .execute()
//                .value
            print("projects \(xprojects)")
        }
        /*
        table.select().execute { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let jsonArray = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]] {
                        self?.projects = jsonArray.map { "\($0)" }  // Adjust mapping to your model
                        //self?.errorMessage = nil
                    } else {
                        //self?.errorMessage = "Failed to parse response"
                    }
                case .failure(let error):
                    //self?.errorMessage = error.localizedDescription
                }
            }
        }*/
    }

    
}
*/

