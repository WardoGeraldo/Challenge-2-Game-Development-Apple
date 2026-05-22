//
//  ArenaScene.swift
//  PaoApp
//
//  Created by Saujana Shafi on 21/05/26.
//

import Foundation
import GameplayKit
import SpriteKit

final class ArenaScene: SKScene {
    let scale: CGFloat

    var entityManager: EntityManager!
    var stateMachine: GKStateMachine!

    // Update time
    var lastUpdateTimeInterval: TimeInterval = 0

    init(
        scale: CGFloat,
    ) {
        let width = CGFloat(kCell) * scale * CGFloat(kColumns)
        let height = CGFloat(kCell) * scale * CGFloat(kRows)

        let size = CGSize(
            width: width,
            height: height,
        )

        self.scale = scale

        super.init(size: size)
    }

    required init?(coder decoder: NSCoder) {
        self.scale = 1.0

        super.init(coder: decoder)
    }

    override func didMove(to view: SKView) {
        entityManager = EntityManager(scene: self)

        configure()
        configureArena()
        configurePlayer()

        stateMachine = GKStateMachine(states: [
            GameStartState(
                entityManager,
            ),
            GameIdleState(
                entityManager,
            ),
            GameAimState(
                entityManager,
            ),

            GameFlyingState(
                entityManager,
            ),
            GameTurnEndState(
                entityManager,
            ),
            GameOverState(
                entityManager,
            ),
        ])

        stateMachine.enter(GameStartState.self)
    }

    func configure() {
        self.backgroundColor = .black
        //        anchorPoint = CGPoint(x: 0.5, y: 0.5)
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
        let playerEntity = PlayerEntity()
        entityManager.add(playerEntity)
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime

        entityManager.update(deltaTime)
        stateMachine.update(deltaTime: deltaTime)
    }
}

// MARK: Collision
extension ArenaScene: SKPhysicsContactDelegate {
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

// MARK: Touch Events
extension ArenaScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.currentState is GameIdleState else { return }

        stateMachine.enter(GameAimState.self)

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
        guard stateMachine.currentState is GameAimState else { return }

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
        guard stateMachine.currentState is GameAimState else { return }

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

        stateMachine.enter(GameFlyingState.self)
    }
}
