//
//  BallEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit
import SpriteKit

// Represents a single flying ball in the active volley.
// VelocityComponent tracks rise/land state; physics velocity lives in SKPhysicsBody.
class BallEntity: GKEntity {
    init(node: SKNode) {
        super.init()
        addComponent(RenderComponent(node))
        addComponent(VelocityComponent())
        if let body = node.physicsBody {
            addComponent(PhysicsComponent(body))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
