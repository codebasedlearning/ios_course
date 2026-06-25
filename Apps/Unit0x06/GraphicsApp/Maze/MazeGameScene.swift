// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import SpriteKit
import CoreMotion


class MazeGameScene: SKScene {
    var wall1: SKSpriteNode!
    var wall2: SKSpriteNode!
    var wall3: SKSpriteNode!
    ///var labelNode: SKLabelNode!
    
    private var motionManager = CMMotionManager()
    var accelerometerData: CMAccelerometerData?
    
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
        self.physicsWorld.gravity = CGVector(dx: 0.5, dy: 0)
        
        // set up the scene
        self.backgroundColor = .lightGray
        
        // add a sprite (ball)
        let ball = createBall(position: CGPoint(x: size.width / 2, y: size.height / 2))
        self.addChild(ball)
        
        startReadingSensors()
        
        // Add another sprite (example wall)
        wall1 = SKSpriteNode(color: .blue, size: CGSize(width: 120, height: 20))
        wall1.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        wall1.physicsBody = SKPhysicsBody(rectangleOf: wall1.size)
        wall1.physicsBody?.isDynamic = false
        self.addChild(wall1)

        wall2 = SKSpriteNode(color: .blue, size: CGSize(width: 120, height: 20))
        wall2.position = CGPoint(x: size.width / 2, y: size.height / 2 - 250)
        wall2.physicsBody = SKPhysicsBody(rectangleOf: wall2.size)
        wall2.physicsBody?.isDynamic = false
        self.addChild(wall2)

        wall3 = SKSpriteNode(color: .blue, size: CGSize(width: 20, height: 120))
        wall3.position = CGPoint(x: size.width / 2 + 150, y: size.height / 2 - 150)
        wall3.physicsBody = SKPhysicsBody(rectangleOf: wall3.size)
        wall3.physicsBody?.isDynamic = false
        self.addChild(wall3)
    }
    
    func startReadingSensors() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, error in
                if let data = data {
                    self?.accelerometerData = data                    
                    self?.physicsWorld.gravity = CGVector(dx: data.acceleration.x*15, dy: data.acceleration.y*15)
                }
            }
        }
    }
    
    func stopReadingSensors() {
        if motionManager.isAccelerometerAvailable {
            motionManager.stopAccelerometerUpdates()
        }
    }

    // called when the scene is about to be removed from its view (e.g. on restart) -
    // make sure the accelerometer doesn't keep running in the background
    override func willMove(from view: SKView) {
        stopReadingSensors()
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
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //if let node = atPoint(location) as? SKSpriteNode, node == wall1 {
        //    return
        //}
                
        let ball = createBall(position: location)
        self.addChild(ball)
    }
    
}

