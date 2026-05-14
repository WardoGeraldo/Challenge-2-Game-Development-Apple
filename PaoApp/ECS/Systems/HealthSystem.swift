//
//  HealthSystem.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

// TODO: [ECS Team] Implement HealthSystem.
//
// HealthSystem handles damage dealt to BlockEntity when a ball hits it.
//
// Required method:
//   /// Reduces the block's health by 1. Returns true if the block is now dead (hp <= 0).
//   func hit(entity: GKEntity, ballCount: Int) -> Bool
//
// Inside hit():
//   1. Get HealthComponent → call healthComponent.hit() (already decrements hp)
//   2. If hp <= 0:
//      a. Nil out the node's physicsBody so no more contacts fire
//      b. Return true (caller animates the death and calls entityManager.untrack/remove)
//   3. Else: update the HP label on the block's RenderComponent.node, return false
//      Label child name convention: "hpLabel" (set by BlockNode)
//
// Reference: ECS_Prototype → HealthSystem.hit(entity:ballCount:)

class HealthSystem: GKComponentSystem<HealthComponent> {

}
