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
        position: CGPoint,
    ) {
        super.init()

        // Visuals
        let node = BlockShapeNode(scale: 1.0)
        addComponent(RenderComponent(node))
        
        // Physics
        let physicsBody = makeBlockPhysicsBody(scale: 1.0)
        addComponent(PhysicsComponent(physicsBody))

        // Logic
        addComponent(HealthComponent(5))
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
