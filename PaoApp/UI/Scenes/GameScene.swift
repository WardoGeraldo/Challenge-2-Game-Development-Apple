//
//  GameScene.swift
//  PaoApp
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

    // MARK: - State Machine
    // TODO: Declare a GKStateMachine property here.
    // private var stateMachine: GKStateMachine!

    // MARK: - Volley tracking
    // TODO: Add volley-tracking properties needed by GameFlyingState:
    // var pendingShotAngle: CGFloat = .pi / 2
    // private var volleyTotal: Int = 0
    // private var volleyLanded: Int = 0
    // private var activeBalls: [SKNode] = []

    // MARK: - Aim line
    // TODO: Add an array to hold aim-line dot nodes used by GameAimingState:
    // private var aimLineNodes: [SKNode] = []

    // MARK: - Shooter origin
    // TODO: Store the shooter's x/y position so states can reference it:
    // private var shootX: CGFloat = 0
    // private var shootY: CGFloat = 0

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

        // TODO: Initialize the state machine with all game states and enter GameStartState:
        // stateMachine = GKStateMachine(states: [
        //     GameStartState(context: self),
        //     GameIdleState(context: self),
        //     GameAimingState(context: self),
        //     GameFlyingState(context: self),
        //     GameTurnEndState(context: self),
        //     GameOverState(context: self)
        // ])
        // stateMachine.enter(GameStartState.self)

        // TODO: Register a UIPanGestureRecognizer and forward its events to the current state:
        // let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        // view.addGestureRecognizer(pan)
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

    override func update(_ currentTime: TimeInterval) {
        let dt: TimeInterval = 1.0 / 60.0
        entityManager.update(dt)

        // TODO: Forward delta time to the state machine each frame:
        // stateMachine.update(deltaTime: dt)

        // TODO: Inside GameFlyingState.update(), detect balls that have returned to shootY
        // and call context.landBall(_:) (or equivalent) to count them as landed.
        // When volleyLanded == volleyTotal the state should transition to GameTurnEndState.
    }
}

// MARK: - Pan Gesture
extension GameScene {
    // TODO: Implement handlePan(_:) to bridge UIKit gesture events into the state machine.
    // @objc private func handlePan(_ g: UIPanGestureRecognizer) {
    //     let raw   = g.translation(in: view)
    //     let angle = clampAngle(dx: raw.x, dy: -raw.y)
    //     switch g.state {
    //     case .began:
    //         if stateMachine.currentState is GameIdleState {
    //             stateMachine.enter(GameAimingState.self)
    //         }
    //         (stateMachine.currentState as? GameAimingState)?.updateAim(angle: angle)
    //     case .changed:
    //         (stateMachine.currentState as? GameAimingState)?.updateAim(angle: angle)
    //     case .ended, .cancelled:
    //         (stateMachine.currentState as? GameAimingState)?.commitShot(angle: angle)
    //     default: break
    //     }
    // }

    // TODO: Implement clampAngle(dx:dy:) to keep the shot angle in the upper hemisphere (≥ 8° from horizontal):
    // private func clampAngle(dx: CGFloat, dy: CGFloat) -> CGFloat {
    //     let min8 = CGFloat(8) * .pi / 180
    //     var a    = atan2(dy, dx)
    //     if dy <= 0 { a = dx >= 0 ? min8 : .pi - min8 }
    //     else       { a = Swift.min(Swift.max(a, min8), .pi - min8) }
    //     return a
    // }
}

// MARK: - Touch Events
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

        // TODO: When the state machine is in GameOverState, delegate the tap to GameOverState.restart()
        // instead of directly re-creating GameScene:
        // if let overState = stateMachine.currentState as? GameOverState {
        //     overState.restart()
        // }
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

// MARK: - Collision
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        contactQueue.append(contact)

        // TODO: Route contact events to CollisionSystem via EntityManager instead of the raw queue.
        // CollisionSystem should:
        // 1. Identify ball↔block vs ball↔pickup contacts using categoryBitMask.
        // 2. Enqueue a CollisionEvent for processing in update().
        // 3. In update(), dequeue events and call HealthSystem.hit(entity:) for blocks
        //    or handle pickup collection for ItemBallEntity.
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

// MARK: - Gyro
extension GameScene {

}

// MARK: - Shooter
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

// MARK: - GameStateContext
// TODO: Make GameScene conform to GameStateContext and implement each required method.
// The protocol drives all state transitions; every method below should be a real implementation
// once the ECS / UI teams complete their respective pieces.
//
// extension GameScene: GameStateContext {
//
//     var shooterPosition: CGPoint {
//         // Return the fixed shooter origin set in setupInitialGame().
//         CGPoint(x: shootX, y: shootY)
//     }
//
//     var isVolleyComplete: Bool {
//         // True when every launched ball has landed.
//         volleyTotal > 0 && volleyLanded >= volleyTotal
//     }
//
//     func setupInitialGame() {
//         // Reset volley counters and physics border, then set shooter position.
//         // TODO: [ECS Team] Spawn the first 3 block rows via EntityManager.
//     }
//
//     func showAimLine(from origin: CGPoint, angle: CGFloat) {
//         // Draw a dotted preview line from origin in the direction of angle.
//         // Store dot nodes in aimLineNodes so they can be removed in hideAimLine().
//     }
//
//     func hideAimLine() {
//         // Remove all aimLineNodes from the scene and clear the array.
//     }
//
//     func fireVolley() {
//         // Set volleyTotal to the player's ball count, reset volleyLanded, then
//         // spawn each ball with a staggered delay (e.g. 0.10 s per ball).
//         // TODO: [ECS Team] Replace hardcoded count with PlayerEntity.ballCount.
//     }
//
//     func advanceBoard() -> Bool {
//         // Move every BlockEntity / ItemBallEntity down one row.
//         // Return true (game over) if any block reaches the shooter row.
//         // Then spawn a fresh row at the top.
//         // TODO: [ECS Team] Implement using EntityManager.entities.
//         return false
//     }
//
//     func showGameOverScreen() {
//         // TODO: [UI Team] Replace placeholder SKLabelNodes with a proper Game Over overlay.
//     }
//
//     func resetGame() {
//         // Remove all game-over labels, balls, and aim-line dots from the scene.
//         // TODO: [ECS Team] Remove all BlockEntity / ItemBallEntity via EntityManager.
//     }
// }
