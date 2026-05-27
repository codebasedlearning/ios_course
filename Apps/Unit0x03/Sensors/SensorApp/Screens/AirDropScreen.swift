// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CblUI

struct AirDropScreen: View {
    @State var sendText: String = "This is a test string for AirDrop."

    var body: some View {
        CblScreen(title: "AirDrop", image: "airdrop2") {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Text:").padding(0)
                    TextField("Enter text here", text: $sendText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(10)
                        .frame(maxWidth: .infinity)
                }
                HStack {
                    Spacer()
                    Button("Drop as Text") { shareText() }
                        .buttonStyle(ScreenButtonStyle())
                    Spacer()
                    Button("Drop as File") { shareTextFile() }
                        .buttonStyle(ScreenButtonStyle())
                    Spacer()
                }
            }.padding(.leading, 10)
        }
    }
    
    private func shareText() {
        let activityViewController = UIActivityViewController(activityItems: [sendText], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.postToFacebook, .postToTwitter, .message, .mail]
        present(activityViewController)
    }

    private func shareTextFile() {
        let fileName = "ios_course_air_drop_test.txt"

        // use the temporary directory — this file only needs to live long enough for the share sheet
        let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try sendText.write(to: filePath, atomically: true, encoding: .utf8)
            let activityViewController = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.postToFacebook, .postToTwitter, .message, .mail]
            present(activityViewController)
        } catch {
            print("Error writing file: \(error)")
        }
    }

    // extracted helper: sets the popover anchor required on iPad, then presents
    private func present(_ activityViewController: UIActivityViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }

        // iPad requires a sourceView/sourceRect for the popover; without it the app crashes
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(
                x: rootViewController.view.bounds.midX,
                y: rootViewController.view.bounds.midY,
                width: 0, height: 0
            )
            popover.permittedArrowDirections = []
        }

        rootViewController.present(activityViewController, animated: true)
    }
}
