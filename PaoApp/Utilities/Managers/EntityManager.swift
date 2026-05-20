//
//  EntityManager.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

//  EntityManager.swift
import Foundation
import GameplayKit
import SpriteKit

protocol AnyComponentSystem {
    func add(foundIn entity: GKEntity)
    func remove(foundIn entity: GKEntity)
    func update(deltaTime: TimeInterval)
}

private struct ComponentSystemBox<T: GKComponent>: AnyComponentSystem {
    let system: GKComponentSystem<T>
    func add(foundIn entity: GKEntity)    { system.addComponent(foundIn: entity) }
    func remove(foundIn entity: GKEntity) { system.removeComponent(foundIn: entity) }
    func update(deltaTime: TimeInterval)  { system.update(deltaTime: deltaTime) }
}

final class EntityManager {
    private(set) var entities: Set<GKEntity> = []
    private var toRemove: Set<GKEntity> = []
    private weak var scene: SKScene?

    lazy var componentSystems: [AnyComponentSystem] = {
        [
            ComponentSystemBox(system: ControllerSystem())
        ]
    }()

    init(scene: SKScene) { self.scene = scene }

    func add(_ entity: GKEntity) {
        entities.insert(entity)
        if let node = entity.component(ofType: RenderComponent.self)?.node {
            scene?.addChild(node)
        }
        for system in componentSystems { system.add(foundIn: entity) }
    }

    func remove(_ entity: GKEntity) {
        entities.remove(entity)
        toRemove.insert(entity)
    }

    func untrack(_ entity: GKEntity) { entities.remove(entity) }

    func entities<T: GKComponent>(with componentType: T.Type) -> [GKEntity] {
        entities.filter { $0.component(ofType: T.self) != nil }
    }

    func entity(forNode node: SKNode) -> GKEntity? {
        entities.first { $0.component(ofType: RenderComponent.self)?.node === node }
    }

    func update(_ deltaTime: TimeInterval) {
        for system in componentSystems { system.update(deltaTime: deltaTime) }
        for entity in toRemove {
            entity.component(ofType: RenderComponent.self)?.node.removeFromParent()
            for system in componentSystems { system.remove(foundIn: entity) }
        }
        toRemove.removeAll()
    }
}
