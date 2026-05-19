//
//  EntityManager.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit
import SpriteKit

// MARK: - RandomManager

// Manages all randomized game values with fair, streak-free distribution
final class RandomManager {
    static let shared = RandomManager()

    // Shuffled deck ensures no HP-tier streaks — the hard block (10) can't
    // appear again until all 9 other cards have been drawn.
    private let blockTierDeck = GKShuffledDistribution(lowestValue: 1, highestValue: 10)

    // TODO: [ECS Team] Register component systems here once systems are implemented.
    // Example:
    //   let healthSystem = GKComponentSystem(componentClass: HealthComponent.self)
    //   return [healthSystem]
    lazy var componentSystems: [GKComponentSystem] = { return [] }()

        let multiplier: Double
        if roll <= 6 {
            multiplier = 0.5       // 60%: easy — half ammo needed
        } else if roll <= 9 {
            multiplier = 1.0       // 30%: fair — full ammo needed
        } else {
            multiplier = 1.5       // 10%: hard — one and a half ammo needed
        }

        let base      = Double(ballCount) * multiplier
        let variance  = Int.random(in: -2...2)
        return max(1, Int(base.rounded()) + variance)
    }

    // Returns a random block type based on which types are unlocked at the current turn
    func randomBlockType(turnNumber: Int) -> BlockType {
        let roll = Int.random(in: 0...99)
        if turnNumber >= 10 && roll < 10 { return .bomb }
        if turnNumber >= 5  && roll < 28 { return .triangle(flipped: Bool.random()) }
        if turnNumber >= 3  && roll < 20 { return .rover }
        return .normal
    }
}

final class EntityManager {
    private(set) var entities: Set<GKEntity> = []
    private weak var scene: SKScene?

    init(scene: SKScene) {
        self.scene = scene
    }

    // Adds entity and its render node to the scene
    func add(_ entity: GKEntity) {
        entities.insert(entity)
        if let node = entity.component(ofType: RenderComponent.self)?.node {
            scene?.addChild(node)
        }
    }

    // Full removal: deregisters entity AND removes its node from the scene immediately
    func remove(_ entity: GKEntity) {
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
        entity.component(ofType: RenderComponent.self)?.node.removeFromParent()
    }

    // Soft removal: deregisters entity from ECS tracking but leaves its node in the scene.
    // Use this when the node has a self-removing animation already running —
    // the animation's .removeFromParent() action handles the visual cleanup.
    func untrack(_ entity: GKEntity) {
        entities.remove(entity)
    }

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
}
