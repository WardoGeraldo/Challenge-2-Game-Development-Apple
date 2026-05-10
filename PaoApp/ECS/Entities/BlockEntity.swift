//
//  Block.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit

class BlockEntity: GKEntity {
    init(
        node: SKShapeNode,
        physicsBody: SKPhysicsBody,
        health: Int,
    ) {
        super.init()

        // Visuals
        addComponent(RenderComponent(node))

        // Physics
        addComponent(PhysicsComponent(physicsBody))

        // Logic
        addComponent(HealthComponent(health))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
