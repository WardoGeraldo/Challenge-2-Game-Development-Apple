//
//  BallEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

//// Represents a single flying ball in the active volley.
//// VelocityComponent tracks rise/land state; physics velocity lives in SKPhysicsBody.
//class BallEntity: GKEntity {
//    init(node: SKNode) {
//        super.init()
//        addComponent(RenderComponent(node))
//        addComponent(VelocityComponent())
//        if let body = node.physicsBody {
//            addComponent(PhysicsComponent(body))
//        }
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

import Foundation
import GameplayKit

class BallEntity: GKEntity {
    init(position: CGPoint) {
        super.init()

        // Sprite
        let node = BallShapeNode(scale: 1.0)
        addComponent(RenderComponent(node))
        addComponent(
            TransformComponent(
                position
            )
        )

        // Physics
        let physicsBody = makeBallPhysicsBody(scale: 1.0)
        addComponent(PhysicsComponent(physicsBody))

        // Velocity
        let velocity = CGVector.zero
        addComponent(VelocityComponent(velocity))

        // Logic
        addComponent(ProjectileComponent(1))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
