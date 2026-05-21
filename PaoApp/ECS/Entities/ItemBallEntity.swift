//
//  ItemBallEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

// Collected when a ball makes contact; behaviour defined by ConsumableComponent.
//class ItemBallEntity: GKEntity {
//    init(node: SKNode, type: PickupType) {
//        super.init()
//        addComponent(RenderComponent(node))
//        addComponent(TransformComponent(node.position, 0))
//        addComponent(ConsumableComponent(type))
//        if let body = node.physicsBody {
//            addComponent(PhysicsComponent(body))
//        }
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

class ItemBallEntity: GKEntity {
    init(
        row: Int,
        col: Int,
    ) {
        super.init()

        // Visuals
        let node = ItemBallSpriteNode(scale: 1.0)
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
        let physicsBody = makeItemBallPhysicsBody(scale: 1.0)
        addComponent(PhysicsComponent(physicsBody))

        // Logic
        let ballEntity = BallEntity(position: position)
        addComponent(
            ConsumableComponent(
                entityToAdd: ballEntity,
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
