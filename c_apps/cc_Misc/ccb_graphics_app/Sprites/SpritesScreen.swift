// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import SpriteKit

struct SpritesScreen: View {
    var scene: SKScene {
        let scene = GameScene1()
        scene.size = CGSize(width: 300, height: 450)
        scene.scaleMode = .fill
        return scene
    }
    
    // one way to reset the scene: change something observed
    @State private var resetID = UUID()
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing:0) {
                Divider()
                HeaderText(text: "Boxes")
                    .padding(.bottom, 5)
                
                // view is designed for scenes, in some examples SpriteKitView: UIViewRepresentable is used
                SpriteView(scene: scene)
                    .id(resetID)
                    .frame(width: geo.size.width*0.9, height: geo.size.height*0.7)
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                    .ignoresSafeArea()
                Button("Restart Scene") {
                    resetID = UUID() // Change the identifier to restart the scene
                }
            }
        }
    }
}

/*
 A scene is the root node of your content.
 It is used to display SpriteKit content on an SKView.
 */
class GameScene1: SKScene {
    var bar: SKSpriteNode!
    var wall1: SKSpriteNode!
    
    // called once after the scene has been initialized,
    // place to perform one-time setup
    override func didMove(to view: SKView) {
        
        // edgeLoopFrom enables physics:
        // Edges have no volume and are intended to be used
        // to create static environments.
        // Edges can collide with body's of volume, but not with
        // each other.
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        //self.physicsBody?.applyForce(CGVector(dx: 100, dy: 0))
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -10)
        
        // set up the scene
        self.backgroundColor = .lightGray
        
        // add a sprite (ball)
        let ball = createBall(position: CGPoint(x: size.width / 2, y: size.height / 2))
        self.addChild(ball)
        
        // Add another sprite (example wall)
        wall1 = SKSpriteNode(color: .orange, size: CGSize(width: 120, height: 20))
        wall1.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        wall1.physicsBody = SKPhysicsBody(rectangleOf: wall1.size)
        wall1.physicsBody?.isDynamic = false
        self.addChild(wall1)
        
        let wall2 = SKSpriteNode(color: .orange, size: CGSize(width: 70, height: 10))
        wall2.position = CGPoint(x: size.width / 10, y: size.height / 2 + 90)
        wall2.zRotation = -10
        wall2.physicsBody = SKPhysicsBody(rectangleOf: wall2.size)
        wall2.physicsBody?.isDynamic = false
        self.addChild(wall2)
        
        let wall3 = SKSpriteNode(color: .orange, size: CGSize(width: 70, height: 10))
        wall3.position = CGPoint(x: size.width / 10 + 250, y: size.height / 2 + 50)
        wall3.zRotation = +10
        wall3.physicsBody = SKPhysicsBody(rectangleOf: wall3.size)
        wall3.physicsBody?.isDynamic = false
        self.addChild(wall3)
    }
    
    func createBall(position: CGPoint) -> SKSpriteNode {
        let ball = SKSpriteNode(imageNamed: "marble3")
        ball.size = CGSize(width: 50, height: 50)
        ball.position = position // center
        // this enables interaction
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.restitution = 0.8 // bouncing
        ball.physicsBody?.friction = 0.2
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.angularDamping = 0.0
        return ball
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        //self.physicsWorld.gravity = CGVector(dx: -10, dy: 0)
        if let node = atPoint(location) as? SKSpriteNode, node == wall1 {
            rotateBar()
            return
        }
        
        let box = SKSpriteNode(color: .darkGray, size: CGSize(width: 40, height: 50))
        box.position = CGPoint(x: location.x-50, y: location.y-10)
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        addChild(box)
        
        let ball = createBall(position: location)
        self.addChild(ball)
    }
    
    func rotateBar() {
        let rotateRight = SKAction.rotate(byAngle: CGFloat.pi / 2, duration: 0.1)
        let rotateLeft = SKAction.rotate(byAngle: -CGFloat.pi / 2 , duration: 0.05)
        let sequence = SKAction.sequence([rotateRight, SKAction.wait(forDuration: 0.15), rotateLeft])
        wall1.run(sequence)
    }
}

/*
 struct SpriteKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
    let view = SKView()
 
    // Create the SpriteKit scene
    let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    scene.scaleMode = .resizeFill
 
    view.presentScene(scene)
    view.ignoresSiblingOrder = true
    view.showsFPS = true
    view.showsNodeCount = true
    ...
 
 func updateUIView(_ uiView: SKView, context: Context) {
    ...
 */

#Preview {
    SpritesScreen()
}
