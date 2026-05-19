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
    init(node: SKNode, hp: Int, type: BlockType) {
        super.init()
        addComponent(RenderComponent(node))
        addComponent(TransformComponent(node.position, 0))
        addComponent(HealthComponent(hp))
        addComponent(BlockTypeComponent(type))

        if let body = node.physicsBody {
            addComponent(PhysicsComponent(body))
        }

        // Rover blocks get their own movement state component
        if type.isRover {
            addComponent(RoverComponent())
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
