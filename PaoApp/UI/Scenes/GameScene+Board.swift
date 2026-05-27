//
//  GameScenePart6.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 19/05/26.
//

import Foundation
import UIKit
import GameplayKit
import SpriteKit
extension GameScene {
    
    // MARK: - Block & Pickup Spawning
    func addBlockEntity(at pos: CGPoint, type: BlockType, hp: Int) {
        let node = BlockNode.make(type: type, hp: hp, ballCount: ballCount, cell: cell)
        node.position = pos

        // Build the physics body and attach it to the node.
        // BlockNode.make() handles visuals only — physics lives here.
        let body = SKPhysicsBody(rectangleOf: CGSize(width: cell * 0.9, height: cell * 0.9))
        body.isDynamic          = false
        body.friction           = 0
        body.restitution        = 1
        body.categoryBitMask    = PhysicsCategory.block
        body.collisionBitMask   = PhysicsCategory.ball
        body.contactTestBitMask = PhysicsCategory.ball
        node.physicsBody = body

        // Detach during the spawn animation so a ball can't hit an invisible block.
        let spawnBody    = node.physicsBody
        node.physicsBody = nil

        // EntityManager.add() reads RenderComponent and calls addChild(node) for us.
        let entity = BlockEntity(node: node, hp: hp, type: type)
        entityManager.add(entity)

        // Re-attach physics once the block has fully appeared.
        node.run(.sequence([
            .wait(forDuration: 0.36),
            .run { [weak node] in
                guard let node, node.parent != nil else { return }
                node.physicsBody = spawnBody
            }
        ]))
    }
    
    func addPickupEntity(at pos: CGPoint, type: PickupType) {
        let node: SKNode
        switch type {
        case .ammo:
            let n = AmmoPickupNode(cell: cell)
            n.position = pos
            node = n
        }
        let entity = ItemBallEntity(node: node, type: type)
        entityManager.add(entity)
    }
    
    // MARK: - Shooter Marker

    func placeShooterMarker() {
        if let prev = playerEntity {
            entityManager.remove(prev)
        }

        // Invisible node — ECS bookkeeping only; panda is the visual
        let node = SKNode()
        node.position = CGPoint(x: shootX, y: shootY)

        let entity = PlayerEntity(node: node)
        entityManager.add(entity)
        playerEntity = entity

        guard let panda = pandaNode else { return }
        let target = CGPoint(x: shootX, y: shootY + 10)
        if panda.parent == nil {
            panda.size = CGSize(width: cell * 1.3, height: cell * 1.3)
            panda.zPosition = 5
            panda.position = target
            addChild(panda)
        } else {
            let move = SKAction.move(to: target, duration: 0.22)
            move.timingMode = .easeInEaseOut
            panda.run(move)
        }
    }
    // MARK: - Board Advance
    // Moves all blocks/pickups down one row. Anything reaching the shooter row is removed (game-over trigger lives in endVolley).
    func advanceBoard() {
        let allBoardEntities = entityManager.entities(with: BlockTypeComponent.self)
        + entityManager.entities(with: ConsumableComponent.self)
        
        for entity in allBoardEntities {
            guard let render = entity.component(ofType: RenderComponent.self) else { continue }
            let node = render.node
            
            let moveDown = SKAction.moveBy(x: 0, y: -step, duration: 0.30)
            moveDown.timingMode = .easeInEaseOut
            
            // Direct position check — more reliable than rounding-based snapping
            let wouldLandAt = node.position.y - step
            
            if wouldLandAt <= shootY + cell / 2 {
                // This entity would enter the shooter row — deregister and animate out.
                // untrack() keeps the node in the scene so the animation plays.
                // entityManager.remove() would call removeFromParent() immediately and
                // cancel the animation, making the block disappear instantly (the teleport bug).
                node.physicsBody = nil
                entityManager.untrack(entity)
                node.run(.sequence([
                    moveDown,
                    .fadeOut(withDuration: 0.15),
                    .removeFromParent()
                ]))
                // Pickups falling off don't end the game — only blocks do
                if entity.component(ofType: BlockTypeComponent.self) != nil {
                    guard !(stateMachine.currentState is GameOverState) else { continue }
                    run(.sequence([
                        .wait(forDuration: 0.5),
                        .run { [weak self] in self?.onGameOver?() }
                    ]))
                }
            } else {
                node.run(moveDown)
            }
        }
        
        run(.sequence([
            .wait(forDuration: 0.08),
            .run { [weak self] in self?.spawnRow(0) }
        ]))
    }

}

