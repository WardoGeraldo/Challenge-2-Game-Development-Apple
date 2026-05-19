//
//  ConsumableComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

// Pickup types available on the board as consumables
enum PickupType {
    case ammo          // adds +1 to ball count
    case portalToken   // next volley warps balls mid-flight
}

// Marks an entity as a one-time consumable pickup
class ConsumableComponent: GKComponent {
    let pickupType: PickupType

    init(_ type: PickupType) {
        self.pickupType = type
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
