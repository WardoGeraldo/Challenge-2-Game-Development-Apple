//
//  CollisionSystem.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit
import SpriteKit

class CollisionSystem: GKComponentSystem<PhysicsComponent> {
    var entityManager: EntityManager

    init(entityManager: EntityManager) {
        self.entityManager = entityManager

        super.init(componentClass: PhysicsComponent.self)
    }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        for physicsComponent in components {
            for contact in physicsComponent.contactQueue {
                guard
                    let nodeA = contact.bodyA.node,
                    let entityA = entityManager.entity(forNode: nodeA),
                    let nodeB = contact.bodyB.node,
                    let entityB = entityManager.entity(forNode: nodeB)
                else {
                    continue
                }

                if let healthComponent = entityA.component(
                    ofType: HealthComponent.self
                ) {
                    healthComponent.hit()
                } else if let healthComponent = entityB.component(
                    ofType: HealthComponent.self
                ) {
                    healthComponent.hit()
                } else if let consumableComponent = entityA.component(
                    ofType: ConsumableComponent.self
                ) {
                    // TODO: Handle player consuming item
                } else if let consumableComponent = entityB.component(
                    ofType: ConsumableComponent.self
                ) {
                    // TODO: Handle player consuming item
                }
            }

            physicsComponent.contactQueue.removeAll()
        }
    }
}
