//
//  ItemBallEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

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
        addComponent(
            TransformComponent(
                position
            )
        )
        addComponent(GridComponent(row: row, col: col))

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

        ScoreManager.shared.addLevel(1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
