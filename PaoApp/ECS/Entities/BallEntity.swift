//
//  BallEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

class BallEntity: GKEntity {
    init(position: CGPoint) {
        super.init()

        // Sprite
        let node = BallShapeNode(scale: 1.0)
        addComponent(RenderComponent(node))

        // Physics
        let physicsBody = makeBallPhysicsBody(scale: 1.0)
        addComponent(PhysicsComponent(physicsBody))

        // Velocity
        let velocity = CGVector(dx: 0, dy: 0)
        addComponent(VelocityComponent(velocity))

        // Logic
        addComponent(ProjectileComponent(1))
        addComponent(
            TransformComponent(
                position
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
