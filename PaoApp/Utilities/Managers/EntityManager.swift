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

    // TODO: Add component systems here
    lazy var componentSystems: [GKComponentSystem] = {
        //        let castleSystem = GKComponentSystem(componentClass: CastleComponent.self)
        //        let moveSystem = GKComponentSystem(componentClass: MoveComponent.self)
        //        return [castleSystem, moveSystem]

        //        let collisionSystem =
        return []
    }()

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

    // TODO: Get Entity
    // Returns all entities that own a given component type
    func entities<T: GKComponent>(with componentType: T.Type) -> [GKEntity] {
        entities.filter { $0.component(ofType: T.self) != nil }
    }

    // Finds the entity whose render node matches the given SKNode
    func entity(forNode node: SKNode) -> GKEntity? {
        entities.first {
            $0.component(ofType: RenderComponent.self)?.node === node
        }
    }

    // TODO: Add helper methods such as generate blocks here?
}
