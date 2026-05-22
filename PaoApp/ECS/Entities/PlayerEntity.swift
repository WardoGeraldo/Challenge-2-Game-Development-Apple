//
//  PlayerEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit

//import SpriteKit
//
//// Represents the shooter — the origin point from which all balls are fired.
//// Holds control state for aiming.
//class PlayerEntity: GKEntity {
//    init(node: SKNode) {
//        super.init()
//        addComponent(RenderComponent(node))
//        addComponent(TransformComponent(node.position, 0))
//        addComponent(ControlComponent(pointTo: node.position))
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

class PlayerEntity: GKEntity {
    override init() {
        super.init()

        // Sprite
        let node = PlayerSpriteNode(scale: 1.0)
        addComponent(RenderComponent(node))
        let position = CGPoint(
            x: CGFloat(kColumns / 2) * kCell + (kCell / 2),
            y: CGFloat(0) * kCell + (kCell / 2)
        )
        addComponent(
            TransformComponent(
                position
            )
        )

        // Logic
        addComponent(
            ControlComponent(
                pointTo: position
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
