//
//  ArenaEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 18/05/26.
//

import Foundation
import GameplayKit

class ArenaEntity: GKEntity {
    init(_ position: CGPoint) {
        super.init()

        // Visuals
        let node = ArenaShapeNode(scale: 1.0)
        addComponent(RenderComponent(node))
        addComponent(
            TransformComponent(
                position,
            )
        )

        // Physics
        let physicsBody = makeArenaPhysicsBody(scale: 1.0)
        addComponent(PhysicsComponent(physicsBody))

        // Arena
        addComponent(ArenaComponent(col: kColumns, row: kRows))

        // Logic
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
