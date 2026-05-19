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

                print("\(entityA) collided with \(entityB)")

                if let healthComponent = entityA.component(
                    ofType: HealthComponent.self
                ),
                    let projectileComponent = entityB.component(
                        ofType: ProjectileComponent.self
                    )
                {
                    healthComponent.hit(demage: projectileComponent.damage)
                    print("Hit")
                } else if let healthComponent = entityB.component(
                    ofType: HealthComponent.self
                ),
                    let projectileComponent = entityA.component(
                        ofType: ProjectileComponent.self
                    )
                {
                    healthComponent.hit(demage: projectileComponent.damage)
                    print("Hit")
                } else if let consumableComponent = entityA.component(
                    ofType: ConsumableComponent.self
                ),
                    entityB.component(
                        ofType: ProjectileComponent.self
                    ) != nil
                {
                    // TODO: Handle player consuming item
                    consumableComponent.onConsumed()
                    print("Consumed")
                } else if let consumableComponent = entityB.component(
                    ofType: ConsumableComponent.self
                ),
                    entityA.component(
                        ofType: ProjectileComponent.self
                    ) != nil
                {
                    // TODO: Handle player consuming item
                    consumableComponent.onConsumed()
                    print("Consumed")
                } else if entityA.component(
                    ofType: GroundComponent.self
                ) != nil,
                    entityB.component(
                        ofType: ProjectileComponent.self
                    ) != nil
                {
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
                    transformComponent.position.x = contact.contactPoint.x
                    playerTransformComponent.position.x = contact.contactPoint.x

                    print("Player hit ground")
                } else {
                    // TODO: Handle game over, because it should only reach here on row touch ground
                    print("Game over")
                }
            }

            physicsComponent.contactQueue.removeAll()
        }
    }
}
