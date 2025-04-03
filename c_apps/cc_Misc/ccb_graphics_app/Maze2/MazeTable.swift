// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation
import SpriteKit
import CoreMotion
import SwiftUI

/*
 Todo: Explain the collision feature and add some walls to do this.
 */

class GameScene2: SKScene {
    var labelNode: SKLabelNode!
    var ball: SKSpriteNode!
    
    public var gravX: Double = 0.0 {
        didSet {
            self.physicsWorld.gravity.dx = gravX
            // print("new x \(gravX)")
        }
    }
    public var gravY: Double = 0.0 {
        didSet {
            self.physicsWorld.gravity.dy = gravY
            // print("new y \(gravY)")
        }
    }

    private var motionManager = CMMotionManager()
    var accelerometerData: CMAccelerometerData?
    
    
    // called once after the scene has been initialized,
    // place to perform one-time setup
    override func didMove(to view: SKView) {
        print("didmove")
        
        // edgeLoopFrom enables physics:
        // Edges have no volume and are intended to be used
        // to create static environments.
        // Edges can collide with body's of volume, but not with
        // each other.
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // set up the scene
        self.backgroundColor = .lightGray
        
        // add a sprite (ball)
        self.ball = createBall(position: CGPoint(x: size.width / 2, y: size.height / 2))
        self.addChild(ball)
        
        // add label manually
        labelNode = SKLabelNode(text: "Sensor")
                labelNode.fontName = "Helvetica"
                labelNode.fontSize = 20
                labelNode.fontColor = .white
        labelNode.position = CGPoint(x: 100, y: 900)
        self.addChild(labelNode)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        // Cleanup your scene here
        print("Scene will move from view")
        stopReadingSensors()
    }
    func reset() {
        ball.removeAllActions()
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball.physicsBody?.angularVelocity = 0
        self.gravX = 0
        self.gravY = 0
    }

    func startReadingSensors() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, error in
                if let data = data {
                    self?.accelerometerData = data
                    self?.labelNode.text = "\(String(format: "%.3f", data.acceleration.x)) \(String(format: "%.3f", data.acceleration.y)) \(String(format: "%.3f", data.acceleration.z))"
                    
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
    
    func createBall(position: CGPoint) -> SKSpriteNode {
        let ball = SKSpriteNode(imageNamed: "marble3")
        ball.size = CGSize(width: 50, height: 50)
        ball.position = position // center
        // this enables interaction
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.restitution = 0.8 // bouncing
        ball.physicsBody?.friction = 10.2
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.angularDamping = 0.0
        return ball
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // guard let touch = touches.first else { return }
        // let location = touch.location(in: self)
        
//        if let node = atPoint(location) as? SKSpriteNode, node == wall1 {
//            ...
//            xxx.physicsBody?.applyForce(CGVector(dx: 100, dy: 0))
//            return
//        }
    }
}

