//
//  Player.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit
import SpriteKit

class PlayerEntity: GKEntity {
    init(node: SKShapeNode, physicsBody: SKPhysicsBody, position: CGPoint) {
        super.init()

        // Sprite
        addComponent(RenderComponent(node))

        // Physics
        addComponent(PhysicsComponent(physicsBody))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
