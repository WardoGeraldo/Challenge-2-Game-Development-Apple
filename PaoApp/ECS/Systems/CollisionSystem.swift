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

                if let projectileComponent = entityA.component(
                    ofType: ProjectileComponent.self
                ) {
                    if let healthComponent = entityB.component(
                        ofType: HealthComponent.self
                    ) {
                        healthComponent.hit(demage: projectileComponent.damage)
                    } else if let consumableComponent = entityB.component(
                        ofType: ConsumableComponent.self
                    ) {
                        // TODO: Handle player consuming item
                        consumableComponent.onConsumed()
                    }
                } else {
                    if entityB.component(
                        ofType: ProjectileComponent.self
                    ) != nil {
                        guard
                            let playerEntity = entityManager.entities(
                                with: ControlComponent.self
                            ).first,
                            let playerTransformComponent =
                                playerEntity.component(
                                    ofType: TransformComponent.self
                                )
                        else { continue }

                        guard
                            let transformComponent = entityB.component(
                                ofType: TransformComponent.self
                            ),
                            let velocityComponent = entityB.component(
                                ofType: VelocityComponent.self
                            )
                        else { continue }

                        velocityComponent.velocity = .zero
                        transformComponent.position = contact.contactPoint
                        playerTransformComponent.position = contact.contactPoint
                    } else if entityB.component(
                        ofType: HealthComponent.self
                    ) != nil {
                        entityManager.remove(entityB)
                    } else if entityB.component(
                        ofType: ConsumableComponent.self
                    ) != nil {
                        entityManager.remove(entityB)
                    }
                }
            }

            physicsComponent.contactQueue.removeAll()
        }
    }
}
