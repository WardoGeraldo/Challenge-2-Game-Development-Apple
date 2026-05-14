//
//  ConsumableComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

// TODO: [ECS Team] Implement ConsumableComponent.
//
// This component marks an entity as a collectible pickup.
//
// Step 1 — Define a PickupType enum (can live here or in a separate file):
//   enum PickupType {
//       case ammo         // +1 ball to the player's volley count
//       case portalToken  // grants a portal-warp charge
//   }
//
// Step 2 — Add a stored property and init:
//   let pickupType: PickupType
//   init(_ type: PickupType) { self.pickupType = type; super.init() }
//
// CollisionSystem reads this component to decide which effect to apply when
// a ball contacts an ItemBallEntity.

class ConsumableComponent: GKComponent {

}
