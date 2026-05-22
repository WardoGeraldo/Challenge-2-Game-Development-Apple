//
//  HealthSystem.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

class HealthSystem: GKComponentSystem<HealthComponent> {
    var entityManager: EntityManager

    init(entityManager: EntityManager) {
        self.entityManager = entityManager

        super.init(componentClass: HealthComponent.self)
    }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        for healthComponent in components {
            guard let entity = healthComponent.entity else { continue }

            if healthComponent.health <= 0 {
                entityManager.remove(entity)
            }
        }
    }
}
