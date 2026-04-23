// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

struct LandingScreen: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        CblScreen(title: "Welcome Screen", image: "lego_background") {
            VStack(spacing: 20) {
                Text("User: \(appViewModel.user)")
                    .font(.title2)
                    .padding()
                
                Text("Score: \(appViewModel.score)")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                // Navigation to Profile
                NavigationLink {
                    ProfileScreen()
                } label: {
                    Label("View Profile", systemImage: "person.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(CblTheme.red)
                        .cornerRadius(10)
                }
                
                // Navigation to Achievements
                NavigationLink {
                    AchievementsScreen()
                } label: {
                    Label("View Achievements", systemImage: "trophy.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(CblTheme.medium)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Profile Screen (Second Level in Stack)

struct ProfileScreen: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    var body: some View {
        CblScreen(title: "Profile", image: "lego_background") {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(CblTheme.light)
                
                Text("Username: \(appViewModel.user)")
                    .font(.title2)
                
                Text("Total Score: \(appViewModel.score)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Divider()
                    .padding()
                
                // Navigate DEEPER - third level
                NavigationLink {
                    EditProfileScreen()
                } label: {
                    Label("Edit Profile", systemImage: "pencil.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(CblTheme.red)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Edit Profile Screen (Third Level in Stack)

struct EditProfileScreen: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var newUsername = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        CblScreen(title: "Edit Profile", image: "lego_background") {
            VStack(spacing: 20) {
                Text("Change Username")
                    .font(.title2)
                    .padding()
                
                TextField("New Username", text: $newUsername)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button {
                    appViewModel.user = newUsername
                    dismiss()  // Go back after saving
                } label: {
                    Text("Save Changes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(CblTheme.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(newUsername.isEmpty)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Achievements Screen (Second Level - Alternative Path)

struct AchievementsScreen: View {
    @Environment(AppViewModel.self) private var appViewModel
    
    let achievements = [
        ("First Win", "trophy.fill", 10),
        ("High Scorer", "star.fill", 50),
        ("Perfect Game", "crown.fill", 100)
    ]
    
    var body: some View {
        CblScreen(title: "Achievements", image: "lego_background") {
            VStack(spacing: 15) {
                Text("Your Achievements")
                    .font(.title2)
                    .padding()
                
                ScrollView {
                    ForEach(achievements, id: \.0) { achievement in
                        HStack {
                            Image(systemName: achievement.1)
                                .font(.title)
                                .foregroundColor(appViewModel.score >= achievement.2 ? .yellow : .gray)
                            
                            VStack(alignment: .leading) {
                                Text(achievement.0)
                                    .font(.headline)
                                Text("Requires \(achievement.2) points")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if appViewModel.score >= achievement.2 {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(CblTheme.dark.opacity(0.3))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
}
