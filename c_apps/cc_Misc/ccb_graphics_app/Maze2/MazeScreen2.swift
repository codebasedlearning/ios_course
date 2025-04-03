// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import SwiftUI
import _SpriteKit_SwiftUI

/*
 
 Under construction...
 
 */


struct MazeScreen2: View {
    @State var scene = GameScene2(size: CGSize(width: 500, height: 1000))

    var body: some View {
        ScreenFrame(header: "– The Maze –", image: "maze") {
            
            GeometryReader { geo in
                SpriteView(scene: scene)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                    .ignoresSafeArea()
                    .onAppear() {
                        scene.startReadingSensors()
                    }
                    .onDisappear() {
                        scene.stopReadingSensors()
                    }
                
            }
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "chevron.up")
                        .padding(10)
                        .border(.white, width: 1)
                        .padding(.top,5)
                        .onTapGesture { scene.gravY += 1 }
                    HStack {
                        Image(systemName: "chevron.left")
                            .onTapGesture { scene.gravX -= 1 }
                            .padding(10)
                            .border(.white, width: 1)
                            //.padding(.trailing, 40)
                        Image(systemName: "clear")
                            .onTapGesture { scene.gravX = 0;  scene.gravY = 0}
                            .padding(10)
                            //.border(.white, width: 1)
                            //.padding(.trailing, 40)
                        Image(systemName: "chevron.right")
                            .onTapGesture { scene.gravX += 1 }
                            .padding(10)
                            .border(.white, width: 1)
                    }
                    Image(systemName: "chevron.down")
                        .onTapGesture { scene.gravY -= 1 }
                        .padding(10)
                        .border(.white, width: 1)
                }
                Spacer()
                Button("Restart Scene") {
                    scene.reset()
                }.buttonStyle(ScreenButtonStyle())
                Spacer()
            }
        }
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
