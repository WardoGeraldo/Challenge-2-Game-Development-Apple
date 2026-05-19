//
//  BlockEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit
import SpriteKit

// Represents a single block on the grid.
// Rover blocks additionally carry a RoverComponent for horizontal movement.
class BlockEntity: GKEntity {
    init(
        health: Int,
    ) {
        super.init()

        // Visuals
        let node = BlockShapeNode(scale: 1.0)
        addComponent(RenderComponent(node))
        addComponent(TransformComponent(node.position, 0))
        addComponent(HealthComponent(hp))
        addComponent(BlockTypeComponent(type))

        // Physics
        let physicsBody = BlockPhysicsBody()
        addComponent(PhysicsComponent(physicsBody))

        // Logic
        addComponent(HealthComponent(health))
        addComponent(
            TransformComponent(
                CGPoint(x: 0, y: 0),
                0
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
