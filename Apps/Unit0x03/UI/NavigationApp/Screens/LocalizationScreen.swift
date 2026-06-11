// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI


/*
 also possible:
  - Text(String("State: "))     // won't be extracted (but also won't localize)
  - Text(verbatim: "State: ")   // explicitly non-localizable
 */


struct LocalizationScreen: View {
    @State private var selectedLocale: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    /// Bundle.main.localizations might return languages you don't actually have translations
    /// for in your String Catalog. For example if your app might include a framework that
    /// supports 10 languages, but your String Catalog only has 4 languages -> filter
    var availableLanguages: [String] {
        Bundle.main.localizations.filter { $0 != "Base" }
    }
    
    var body: some View {
        CblScreen(title: "Localization Demo", image: "lego_background") {
            VStack {
                // Show current system locale
                Text("Current System Language: \(currentLanguageDisplay)")
                    .font(.caption)
                    .foregroundStyle(.primary)
                
                Divider()
                
                // Show available languages from bundle
                VStack(alignment: .leading, spacing: 12) {
                    Text("Available Languages in App:")
                        .font(.headline)
                    
                    ForEach(availableLanguages, id: \.self) { langCode in
                        HStack {
                            Text(flagEmoji(for: langCode))
                            Text(displayName(for: langCode))
                                .font(.body)
                            Spacer()
                            Text("(\(langCode))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Divider()
                
                // Show all connection states with their localized names
                VStack(alignment: .leading, spacing: 12) {
                    Text("Connection States:")
                        .font(.headline)
                    
                    ForEach([ConnectionState.online, .offline, .error], id: \.self) { state in
                        HStack {
                            Circle()
                                .fill(colorForState(state))
                                .frame(width: 12, height: 12)
                            
                            Text(state.displayName)
                                .font(.body)
                            
                            Spacer()
                            
                            Text("(\(String(describing: state).capitalized))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Divider()
                
                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("To test localization:")
                        .font(.headline)
                    
                    Group {
                        Text("1. On Device/Simulator:")
                        Text("   Settings → General → Language & Region")
                            .font(.caption)
                        
                        Text("2. In Xcode:")
                        Text("   Edit Scheme (⌘⇧<) → Run → App Language")
                            .font(.caption)
                        
                        Text("3. Available languages:")
                        Text("   \(availableLanguagesList)")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Helper Properties
    
    private var currentLanguageDisplay: String {
        let code = Locale.current.language.languageCode?.identifier ?? "unknown"
        return "\(displayName(for: code)) (\(code))"
    }
    
    private var availableLanguagesList: String {
        availableLanguages.map { displayName(for: $0) }.joined(separator: ", ")
    }
        
    private func displayName(for localeIdentifier: String) -> String {
        // Use current locale to get localized language name
        Locale.current.localizedString(forLanguageCode: localeIdentifier) 
            ?? localeIdentifier.uppercased()
    }
    
    private func flagEmoji(for languageCode: String) -> String {
        // Map language codes to flag emojis
        switch languageCode {
        case "en": return "🇬🇧"
        case "de": return "🇩🇪"
        case "es": return "🇪🇸"
        case "fr": return "🇫🇷"
        default: return "🌐"
        }
    }
    
    private func colorForState(_ state: ConnectionState) -> Color {
        switch state {
        case .online: return .green
        case .offline: return .orange
        case .error: return .red
        }
    }
}

// make ConnectionState hashable for ForEach
//extension ConnectionState: Hashable {}

#Preview {
    LocalizationScreen()
}
