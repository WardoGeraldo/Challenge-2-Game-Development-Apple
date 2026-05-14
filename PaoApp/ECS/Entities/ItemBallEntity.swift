//
//  ItemBallEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

// TODO: [ECS Team] Implement ItemBallEntity.
// ItemBallEntity represents collectible pickups on the board (ammo or portal token).
//
// Required components:
//   - RenderComponent(node)     → visual node (ammo circle or portal hexagon)
//   - PhysicsComponent(body)    → static body (isDynamic = false)
//     categoryBitMask  = PhysicsCategory.pickup   ← add this category to PhysicsCategory.swift
//     contactTestBitMask = PhysicsCategory.ball
//   - ConsumableComponent(type) → stores the pickup type (.ammo / .portalToken)
//
// Expected init signature:
//   init(node: SKNode, type: PickupType)   ← define PickupType enum if not yet defined
//
// When a ball contacts the pickup, CollisionSystem should:
//   1. Call entityManager.remove(itemBallEntity)
//   2. Apply effect (ammo: ballCount += 1 / portal: portalCharges += 1)
//
// Reference: ECS_Prototype → GameScene.addPickupEntity(at:type:) + handlePickupCollected(node:)

class ItemBallEntity: GKEntity {

}
