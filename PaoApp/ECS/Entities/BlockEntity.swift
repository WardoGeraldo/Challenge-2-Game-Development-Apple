//
//  BlockEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit

class BlockEntity: GKEntity {
    init(
        row: Int,
        col: Int,
    ) {
        super.init()

        // Visuals
        let node = BlockSpriteNode(scale: 0.9)
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
        let physicsBody = makeBlockPhysicsBody(scale: 0.9)
        addComponent(PhysicsComponent(physicsBody))

        // Logic
        let health =
            ScoreManager.shared.currentLevel + kProjectileInitial
            + RandomManager.shared.getRandomVariance()
        addComponent(HealthComponent(health))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
