// (C) 2024 A.Voß, a.voss@fh-aachen.de, ios@codebasedlearning.dev

import SwiftUI
import AVFoundation
import AVKit
import WebKit

/*
 
 Under construction...
 
 */


/*
 Todo: - There are many errors seen in the debug window.
       - Dealing with the resources was tricky, loading direct from
         the resources failed, only the path-way worked.
 */

struct MediaScreen: View {
    @StateObject var audioPlayerViewModel = AudioPlayerViewModel()

    var body: some View {
        ScreenFrame(header: "– Media –") {
            
            VStack {
                // video playback
                let path1 = Bundle.main.path(forResource: "video3", ofType: "mov")
                if let path=path1 {
                    let url = URL(fileURLWithPath: path)
                    
                    //if let videoURL = Bundle.main.url(forResource: "213616_tiny", withExtension: "mp4") {
                    AVPlayerViewX(player: AVPlayer(url: url))
                        .frame(height: 300)
                } else {
                    Text("Video not found")
                }
 
                Button(action: {
                        audioPlayerViewModel.playOrPause()
                      }) {
                        Image(systemName: audioPlayerViewModel.isPlaying ? "pause.circle" : "play.circle")
                          .resizable()
                          .frame(width: 64, height: 64)
                      }
                      .buttonStyle(ScreenButtonStyle())
                      .padding(5)
            }
        }
    }
}

struct AVPlayerViewX: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    }
}

class AudioPlayerViewModel: ObservableObject {
  var audioPlayer: AVAudioPlayer?

  @Published var isPlaying = false

  init() {
      if let sound = Bundle.main.path(forResource: "music3x", ofType: "m4a") {
          do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound))
          } catch {
            print("AVAudioPlayer could not be instantiated.")
          }
      } else {
          print("Audio file could not be found.")
      }
  }

  func playOrPause() {
      guard let player = audioPlayer else { return }

      if player.isPlaying {
          player.pause()
          isPlaying = false
      } else {
          player.play()
          isPlaying = true
      }
  }
}

struct WebViewScreen: View {
    var body: some View {
        ScreenFrame(header: "– AMI Prepared –") {
            WebView(url: URL(string: "https://youtu.be/sDlQTePAV48")!)
                .frame(maxWidth:.infinity, maxHeight: .infinity)
                .cornerRadius(10)
                .padding()
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct ScreenFrame<Content: View>: View {
    var header: String
    var image: String?
    let content: Content
    
    @State private var selectedTab: Int = 0
    
    init(header: String, image: String? = nil, @ViewBuilder content: () -> Content) {
        self.header = header
        self.image = image
        self.content = content()
    }
    
    var body: some View {
            VStack(spacing: 0) {
                HeaderText(text: header)
                GeometryReader { geo in
                ZStack {
                    if let image = image {
                        
                        Image(image)
                            .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        // .scaleEffect(1)
                        // .offset(x: 0, y: 0)
                        .opacity(0.2)
                        .clipped()
                    }
                    
                    VStack(spacing: 0) {
                        content
                        Spacer()
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                }
                
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(AppColors.amiFg.color, width: 1)
                .background(AppColors.amiBg.color.opacity(0.5))
            }.padding(0)
        }
    }
}

enum AppColors {
    case headBg
    case headFg
    case stdFg
    case amiFg
    case amiBg
    case amiBgAlt
    case amiRed
    case custom(String)
    
    var color: Color {
        switch self {
            
        case .headBg:
            return colorFromHex("#363752")
        case .headFg:
            return colorFromHex("#A8ADFF")
        case .stdFg:
            return .white
        case .amiFg:
            return colorFromHex("#A8ADFF")
        case .amiBg:
            return colorFromHex("#363752")
        case .amiBgAlt:
            return colorFromHex("#8789CA")
        case .amiRed:
            return colorFromHex("#941100")
        case .custom(let hex):
            return colorFromHex(hex)
        }
    }
}

func colorFromHex(_ hex: String) -> Color {
    var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    if hex.hasPrefix("#") {
        hex.removeFirst()
    }

    guard hex.count == 6 else {
        return Color.gray // return default color if hex string invalid
    }

    var rgbValue: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&rgbValue)

    let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
    let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
    let blue = Double(rgbValue & 0x0000FF) / 255.0

    return Color(red: red, green: green, blue: blue)
}

struct ScreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(AppColors.amiBg.color)
            .foregroundColor(AppColors.stdFg.color)
            //.border(AppColors.amiFg.color, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            //.cornerRadius(8)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColors.amiFg.color, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            
    }
}
