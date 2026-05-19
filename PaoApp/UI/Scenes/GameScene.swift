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
    var stateMachine: GKStateMachine!

    // Update time
    var lastUpdateTimeInterval: TimeInterval = 0

    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override func didMove(to view: SKView) {
        entityManager = EntityManager(scene: self)

        stateMachine = GKStateMachine(states: [
            GameStartState(entityManager),
            GameIdleState(entityManager),
            GameAimState(entityManager),
            GameFlyingState(entityManager),
            GameTurnEndState(entityManager),
            GameOverState(entityManager),
        ])

        configure()

        configureArena()

        configurePlayer()

        configureBlock()
    }

    func configure() {
        self.backgroundColor = .black
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }

    private func configureArena() {
        let position = CGPoint.zero

        let arenaEntity = ArenaEntity(
            position
        )
        entityManager.add(arenaEntity)

        let groundEntity = GroundEntity(
            position
        )
        entityManager.add(groundEntity)
    }

    private func configurePlayer() {
        guard
            let arenaEntity = entityManager.entities(with: ArenaComponent.self)
                .first,
            let transformComponent = arenaEntity.component(
                ofType: TransformComponent.self
            )
        else {
            return
        }

        let position = CGPoint(
            x: transformComponent.position.x,
            y: transformComponent.position.y - (kCell * 4)
        )

        let playerEntity = PlayerEntity(
            position: position
        )
        entityManager.add(playerEntity)

        entityManager.add(
            BallEntity(
                position: position
            )
        )
        entityManager.add(
            BallEntity(
                position: position
            )
        )
        entityManager.add(
            BallEntity(
                position: position
            )
        )
    }

    private func configureBlock() {
        guard
            let arenaEntity = entityManager.entities(with: ArenaComponent.self)
                .first,
            let transformComponent = arenaEntity.component(
                ofType: TransformComponent.self
            )
        else {
            return
        }

        let blockEntity = BlockEntity(
            position: CGPoint(
                x: transformComponent.position.x,
                y: transformComponent.position.y
            )
        )
        entityManager.add(blockEntity)
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime

        entityManager.update(deltaTime)
    }
}

// MARK: Touch Events
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let playerEntity = entityManager.entities(
                with: ControlComponent.self
            ).first,
            let controlComponent = playerEntity.component(
                ofType: ControlComponent.self
            ),
            let point = touches.first?.location(in: self)
        else { return }

        controlComponent.orient(to: point)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let playerEntity = entityManager.entities(
                with: ControlComponent.self
            ).first,
            let controlComponent = playerEntity.component(
                ofType: ControlComponent.self
            ),
            let point = touches.first?.location(in: self)
        else { return }

        controlComponent.orient(to: point)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let projectiles = entityManager.entities(with: ProjectileComponent.self)

        guard
            let playerEntity = entityManager.entities(
                with: ControlComponent.self
            ).first,
            let controlComponent = playerEntity.component(
                ofType: ControlComponent.self
            ),
            let point = touches.first?.location(in: self)
        else { return }

        controlComponent.orient(to: point)
        controlComponent.projectiles = projectiles

        //        if let point = touches.first?.location(in: self) {
        //            fireBall(to: point)
        //        }
    }
}

//MARK: Collision
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard
            let nodeA = contact.bodyA.node,
            let entityA = entityManager.entity(forNode: nodeA)
        else { return }

        guard
            let physicsComponentA = entityA.component(
                ofType: PhysicsComponent.self
            )
        else {
            return
        }

        physicsComponentA.contactQueue.append(
            contact
        )
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
