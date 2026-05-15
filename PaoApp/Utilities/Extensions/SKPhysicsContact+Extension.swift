//
//  SKPhysicsContact+Extension.swift
//  PaoApp
//
//  Created by Saujana Shafi on 13/05/26.
//

import Foundation
import GameplayKit
import SpriteKit

class PhysicsContact {
    var entityA: GKEntity

    var entityB: GKEntity

    init(
        entityA: GKEntity,
        entityB: GKEntity,
    ) {
        self.entityA = entityA
        self.entityB = entityB
    }
}
