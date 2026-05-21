//
//  BlockEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit

//import SpriteKit
//
//class BlockEntity: GKEntity {
//    init(node: SKNode, hp: Int, type: BlockType) {
//        super.init()
//        addComponent(RenderComponent(node))
//        addComponent(TransformComponent(node.position, 0))
//        addComponent(HealthComponent(hp))
//        addComponent(BlockTypeComponent(type))
//
//        // Physics body is nil during spawn animation — added here only if present
//        if let body = node.physicsBody {
//            addComponent(PhysicsComponent(body))
//        }
//
//        if type.isRover {
//            addComponent(RoverComponent())
//        }
//    }
//
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//}

class BlockEntity: GKEntity {
    init(
        row: Int,
        col: Int,
    ) {
        super.init()

        // Visuals
        let node = BlockShapeNode(scale: 1.0)
        addComponent(RenderComponent(node))
        let position = CGPoint(
            x: CGFloat(col) * kCell + (kCell / 2),
            y: CGFloat(row) * kCell + (kCell / 2)
        )
        addComponent(GridComponent(row: row, col: col))
        addComponent(
            TransformComponent(
                position
            )
        )

        // Physics
        let physicsBody = makeBlockPhysicsBody(scale: 1.0)
        addComponent(PhysicsComponent(physicsBody))

        // Logic
        addComponent(HealthComponent(5))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
