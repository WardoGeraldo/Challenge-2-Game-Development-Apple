//
//  GroundEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 19/05/26.
//

import Foundation
import GameplayKit

class GroundEntity: GKEntity {
    init(_ position: CGPoint) {
        super.init()

        let node = GroundShapeNode(scale: 1.0)
        addComponent(RenderComponent(node))

        let physicsBody = makeGroundPhysicsBody(scale: 1.0)
        addComponent(PhysicsComponent(physicsBody))

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
