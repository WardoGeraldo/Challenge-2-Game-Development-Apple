//
//  GameScene.swift
//  Game101
//
//  Created by Saujana Shafi on 27/04/26.
//

import GameplayKit
import SpriteKit
import SwiftUI

final class GameScene: SKScene {
    var entityManager: EntityManager!

    private var score: Int = 0

    private var isGameOver: Bool = false

    // Physics Contact
    var contactQueue = [SKPhysicsContact]()

    private var shooterNode: SKShapeNode!
    private var blockNode: SKShapeNode!

    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override func didMove(to view: SKView) {
        entityManager = EntityManager(scene: self)

        configure()

        configureWalls()

        configureBlock()
    }

    func configure() {
        self.backgroundColor = .black
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }

    func configurePlayer() {

    }

    private func configureWalls() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)

        self.physicsBody?.friction = 0.0  // No resistance when sliding
        self.physicsBody?.restitution = 1.0  // Perfectly "bouncy" (1.0 = 100% energy kept)
        //        self.physicsBody?.categoryBitMask = kWallCategory
        //        self.physicsBody?.collisionBitMask = kBallCategory
        self.physicsBody?.usesPreciseCollisionDetection = true
    }

    private func configureBlock() {
        let block = SKSpriteNode(
            color: .systemBlue,
            size: CGSize(width: 30, height: 30)
        )
        //        block.name = kBlockName

        block.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

        // Setup Physics
        block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
        block.physicsBody?.isDynamic = false  // Static so it doesn't fall or move when hit
        //        block.physicsBody?.categoryBitMask = kBlockCategory
        //        block.physicsBody?.contactTestBitMask = kBallCategory
        block.physicsBody?.friction = 0.0
        block.physicsBody?.restitution = 1.0

        // Add the Label
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "5"  // Set initial hit count
        label.fontSize = 16
        label.fontColor = .white
        label.name = "hpLabel"

        // Center the label inside the block
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        block.addChild(label)
        self.addChild(block)
    }
}

// MARK: Touch Events
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            let gameScene = GameScene(size: self.size)
            self.view?.presentScene(
                gameScene,
                transition: .fade(withDuration: 1.0)
            )
        }

        if let point = touches.first?.location(in: self) {
            orientShooter(to: point)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            orientShooter(to: point)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            fireBall(to: point)
        }
    }
}

//MARK: Collision
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        contactQueue.append(contact)
    }

    func handle(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.parent == nil
            || contact.bodyB.node?.parent == nil
        {
            return
        }

        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]

        print("Something Hit")

        // Block Hit
        //        if nodeNames.contains(kBlockName) && nodeNames.contains(kBallName) {
        //            print("Block Hit")
        //
        //            let blockNode =
        //                contact.bodyA.node?.name == kBlockName
        //                ? contact.bodyA.node : contact.bodyB.node
        //            if let block = blockNode {
        //                handleBlockHit(block)
        //            }
        //        }
    }

    func processContacts(forUpdate currentTime: CFTimeInterval) {
        for contact in contactQueue {
            handle(contact)
            if let index = contactQueue.firstIndex(of: contact) {
                contactQueue.remove(at: index)
            }
        }
    }
}

// MARK: Gyro
extension GameScene {

}

// MARK: Shooter
extension GameScene {
    func orientShooter(to point: CGPoint) {
        let ship = childNode(withName: "shooter")

        let lookAtConstraint = SKConstraint.orient(
            to: point,
            offset: SKRange(constantValue: -CGFloat.pi / 2)
        )
        ship?.constraints = [lookAtConstraint]
    }

    func fireBall(to point: CGPoint) {
        //        guard let shooter = childNode(withName: kShooterName) as? ShooterNode
        //        else { return }

        //        let from = shooter.position
        //        let ball = getBallNode(position: from)
        //        self.addChild(ball)

        // 1. Calculate direction vector
        //        let direction = (point - from).normalized()

        // 2. Define a constant speed
        let speed: CGFloat = 400.0

        // 3. Apply velocity directly to the physics body
        //        ball.physicsBody?.velocity = CGVector(
        //            dx: direction.x * speed,
        //            dy: direction.y * speed
        //        )
    }

    func handleBlockHit(_ block: SKNode) {
        // 1. Find the label child
        guard let label = block.childNode(withName: "hpLabel") as? SKLabelNode,
            let currentText = label.text,
            var hp = Int(currentText)
        else { return }

        // 2. Decrease HP
        hp -= 1

        if hp <= 0 {
            // 3. Destroy the block
            block.removeFromParent()
            // Optional: Add an explosion effect here
        } else {
            // 4. Update the label and maybe change block appearance
            label.text = "\(hp)"

            // Visual feedback: make the block pulse when hit
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.05),
                SKAction.scale(to: 1.0, duration: 0.05),
            ])
            block.run(pulse)
        }
    }
}
