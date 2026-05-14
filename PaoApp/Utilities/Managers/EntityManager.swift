//
//  EntityManager.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

final class EntityManager {
    var entities = Set<GKEntity>()
    let scene: SKScene

    // TODO: [ECS Team] Register component systems here once systems are implemented.
    // Example:
    //   let healthSystem = GKComponentSystem(componentClass: HealthComponent.self)
    //   return [healthSystem]
    lazy var componentSystems: [GKComponentSystem] = { return [] }()

    var toRemove = Set<GKEntity>()

    init(scene: SKScene) {
        self.scene = scene
    }

    func add(_ entity: GKEntity) {
        entities.insert(entity)

        if let skNode = entity.component(ofType: RenderComponent.self)?.node {
            scene.addChild(skNode)
        }

        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }
    }

    func remove(_ entity: GKEntity) {
        if let skNode = entity.component(ofType: RenderComponent.self)?.node {
            skNode.removeFromParent()
        }

        entities.remove(entity)
        toRemove.insert(entity)
    }

    // TODO: [ECS Team] Add untrack(_:) — removes from the ECS registry without calling removeFromParent().
    // This is needed when a death animation still needs to play after the entity is "dead":
    //   func untrack(_ entity: GKEntity) {
    //       entities.remove(entity)
    //       toRemove.insert(entity)
    //   }

    // TODO: [ECS Team] Add entity(forNode:) — reverse lookup from SKNode to GKEntity.
    // Used by CollisionSystem and HealthSystem to find which entity was hit:
    //   func entity(forNode node: SKNode) -> GKEntity? {
    //       return entities.first {
    //           $0.component(ofType: RenderComponent.self)?.node === node
    //       }
    //   }

    // TODO: [ECS Team] Add entities(with:) — query all entities that have a given component type.
    // Used by GameScene.advanceBoard() to loop over blocks and pickups:
    //   func entities<T: GKComponent>(with componentClass: T.Type) -> [GKEntity] {
    //       return entities.filter { $0.component(ofType: componentClass) != nil }
    //   }

    func update(_ deltaTime: CFTimeInterval) {
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }

        for currentRemove in toRemove {
            for componentSystem in componentSystems {
                componentSystem.removeComponent(foundIn: currentRemove)
            }
        }

        toRemove.removeAll()
    }
}
