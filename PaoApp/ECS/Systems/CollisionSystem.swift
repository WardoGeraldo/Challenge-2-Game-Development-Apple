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

                if entityA.component(
                    ofType: HealthComponent.self
                ) != nil,
                    entityB.component(
                        ofType: ProjectileComponent.self
                    ) != nil
                {
                    handleBlockProjectileHit(
                        blockEntity: entityA,
                        projectileEntity: entityB,
                    )
                } else if entityB.component(
                    ofType: HealthComponent.self
                ) != nil,
                    entityA.component(
                        ofType: ProjectileComponent.self
                    ) != nil
                {
                    handleBlockProjectileHit(
                        blockEntity: entityB,
                        projectileEntity: entityA,
                    )
                } else if entityA.component(
                    ofType: ConsumableComponent.self
                ) != nil,
                    entityB.component(
                        ofType: ProjectileComponent.self
                    ) != nil
                {
                    // TODO: Handle player consuming item
                    handleItemProjectileHit(
                        itemEntity: entityA,
                        projectileEntity: entityB,
                    )
                } else if entityB.component(
                    ofType: ConsumableComponent.self
                ) != nil,
                    entityA.component(
                        ofType: ProjectileComponent.self
                    ) != nil
                {
                    // TODO: Handle player consuming item
                    handleItemProjectileHit(
                        itemEntity: entityB,
                        projectileEntity: entityA,
                    )
                } else if entityA.component(
                    ofType: GroundComponent.self
                ) != nil,
                    entityB.component(
                        ofType: ProjectileComponent.self
                    ) != nil
                {
                    handleGroundProjectileHit(
                        contact,
                        projectileEntity: entityB,
                    )
                } else if entityB.component(ofType: GroundComponent.self)
                    != nil,
                    entityA.component(ofType: ProjectileComponent.self) != nil
                {
                    handleGroundProjectileHit(
                        contact,
                        projectileEntity: entityA,
                    )
                } else {
                    // TODO: Handle game over, because it should only reach here on row touch ground
                    //                    handleGroundBlockHit()
                    print("Ini apaan cuk")
                }
            }

            physicsComponent.contactQueue.removeAll()
        }
    }

    private func handleBlockProjectileHit(
        blockEntity: GKEntity,
        projectileEntity: GKEntity
    ) {
        guard
            let healthComponent = blockEntity.component(
                ofType: HealthComponent.self
            ),
            let projectileComponent = projectileEntity.component(
                ofType: ProjectileComponent.self
            )
        else { return }

        healthComponent.hit(damage: projectileComponent.damage)
    }

    private func handleItemProjectileHit(
        itemEntity: GKEntity,
        projectileEntity: GKEntity
    ) {
        guard
            let consumableComponent = itemEntity.component(
                ofType: ConsumableComponent.self
            ),
            projectileEntity.component(
                ofType: ProjectileComponent.self
            ) != nil
        else { return }

        guard
            let playerEntity = entityManager.entities(
                with: ControlComponent.self
            ).first,
            let playerTransformComponent =
                playerEntity.component(
                    ofType: TransformComponent.self
                )
        else { return }

        // TODO: Handle player consuming item
        guard
            let transformComponent = consumableComponent
                .entityToAdd
                .component(ofType: TransformComponent.self)
        else { return }

        transformComponent.position.y =
            playerTransformComponent.position.y

        entityManager.add(consumableComponent.entityToAdd)

        entityManager.remove(itemEntity)
    }

    private func handleGroundProjectileHit(
        _ contact: SKPhysicsContact,
        projectileEntity: GKEntity
    ) {
        guard
            let playerEntity = entityManager.entities(
                with: ControlComponent.self
            ).first,
            let playerTransformComponent =
                playerEntity.component(
                    ofType: TransformComponent.self
                ),
            let playerControlComponent = playerEntity.component(
                ofType: ControlComponent.self
            )
        else { return }

        guard
            let transformComponent = projectileEntity.component(
                ofType: TransformComponent.self
            ),
            let velocityComponent = projectileEntity.component(
                ofType: VelocityComponent.self
            )
        else { return }

        velocityComponent.velocity = .zero
        transformComponent.position.x = contact.contactPoint.x

        if playerControlComponent.nextRoundPosition == nil {
            playerControlComponent.nextRoundPosition = CGPoint(
                x: contact.contactPoint.x,
                y: playerTransformComponent.position.y,
            )
        }
    }
}
