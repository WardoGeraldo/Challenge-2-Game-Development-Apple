//
//  ItemBallEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit
import SpriteKit

// Represents a floor pickup (ammo or portal token).
// Collected when a ball makes contact; behaviour defined by ConsumableComponent.
class ItemBallEntity: GKEntity {
    init(node: SKNode, type: PickupType) {
        super.init()
        addComponent(RenderComponent(node))
        addComponent(TransformComponent(node.position, 0))
        addComponent(ConsumableComponent(type))
        if let body = node.physicsBody {
            addComponent(PhysicsComponent(body))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
