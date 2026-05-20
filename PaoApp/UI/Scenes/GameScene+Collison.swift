//
//  GameScene+Collison.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 19/05/26.
//

import Foundation
import GameplayKit
import SpriteKit
import UIKit

extension GameScene {

    // MARK: - Contact Detection
    // Enqueues events instead of handling them directly — physics world is locked during didBegin.
    func didBegin(_ contact: SKPhysicsContact) {
        let a    = contact.bodyA.categoryBitMask
        let b    = contact.bodyB.categoryBitMask
        let pair = a | b

        // Ball ↔ Block
        if pair == PhysicsCategory.ball | PhysicsCategory.block {
            guard let ballNode  = (a == PhysicsCategory.ball  ? contact.bodyA : contact.bodyB).node,
                  let blockNode = (a == PhysicsCategory.block ? contact.bodyA : contact.bodyB).node
            else { return }
            collisionSystem.enqueue(CollisionEvent(ballNode: ballNode, otherNode: blockNode, isBlock: true))
        }

        // Ball ↔ Pickup
        if pair == PhysicsCategory.ball | PhysicsCategory.pickup {
            guard let ballNode   = (a == PhysicsCategory.ball   ? contact.bodyA : contact.bodyB).node,
                  let pickupNode = (a == PhysicsCategory.pickup ? contact.bodyA : contact.bodyB).node
            else { return }
            collisionSystem.enqueue(CollisionEvent(ballNode: ballNode, otherNode: pickupNode, isBlock: false))
        }
    }
    
    // MARK: - Block Hit Handling
    
    func handleBlockHit(node: SKNode) {
        guard let entity = entityManager.entity(forNode: node) else { return }
        animateBlockHit(node)
        
        let dead = healthSystem.hit(entity: entity, ballCount: ballCount)
        
        if dead {
            let isBomb = entity.component(ofType: BlockTypeComponent.self)?.blockType.isBomb ?? false
            
            // Deregister from ECS first so no further hits are processed for this node.
            // physicsBody is already nil'd by HealthSystem — do NOT call entityManager.remove()
            // here because that would call node.removeFromParent() and cancel the death animation.
            entityManager.untrack(entity)
            
            if isBomb {
                explode(at: node.position)
                HapticManager.shared.play(.heavy)
            } else {
                HapticManager.shared.play(.rigid)
            }
            
            movementSystem.unstickRovers(near: node.position,
                                         entityManager: entityManager,
                                         cell: cell)
            // Animation handles its own removeFromParent() at the end
            animateBlockDeath(node: node, isBomb: isBomb)
        } else {
            let hp    = entity.component(ofType: HealthComponent.self)?.health ?? 1
            let ratio = CGFloat(hp) / CGFloat(max(ballCount, 1))
            if ratio < 0.5 {
                HapticManager.shared.play(.medium)
            } else {
                HapticManager.shared.play(.light)
            }
        }
    }
    
    func animateBlockHit(_ node: SKNode) {
        
        guard let sprite =
                node.childNode(withName: "blockSprite")
                as? SKSpriteNode
        else { return }
        
        sprite.removeAction(forKey: "hitAnim")
        
        let hit = SKAction.sequence([
            
            .group([
                
                .scaleX(to: 0.88, duration: 0.045),
                .scaleY(to: 1.08, duration: 0.045)
                
            ]),
            
                .group([
                    
                    .scaleX(to: 1.0, duration: 0.08),
                    .scaleY(to: 1.0, duration: 0.08)
                    
                ])
        ])
        
        hit.timingMode = .easeOut
        
        sprite.run(
            hit,
            withKey: "hitAnim"
        )
        
        let shake = SKAction.sequence([
            
            .moveBy(x: -2, y: 0, duration: 0.02),
            .moveBy(x:  4, y: 0, duration: 0.04),
            .moveBy(x: -2, y: 0, duration: 0.02)
        ])
        
        node.run(shake)
    }
    
    func animateBlockDeath(node: SKNode, isBomb: Bool) {
        let scale: CGFloat = isBomb ? 1.5 : 1.2
        node.run(.sequence([
            .group([
                .scale(to: scale, duration: 0.07),
                .fadeOut(withDuration: 0.09)
            ]),
            .removeFromParent()
        ]))
    }
    
    // MARK: - Bomb Explosion
    
    func explode(at pos: CGPoint) {
        // Expanding blast ring
        let ring = SKShapeNode(circleOfRadius: 4)
        ring.fillColor   = .clear
        ring.strokeColor = UIColor(red: 1.0, green: 0.55, blue: 0.2, alpha: 0.9)
        ring.lineWidth   = 3
        ring.position    = pos
        ring.zPosition   = 8
        addChild(ring)
        ring.run(.sequence([
            .group([
                .scale(to: (cell * 2.8) / 4, duration: 0.35),
                .sequence([.wait(forDuration: 0.15), .fadeOut(withDuration: 0.20)])
            ]),
            .removeFromParent()
        ]))
        
        // Sparks
        for _ in 0..<10 {
            let spark = SKShapeNode(circleOfRadius: 3)
            spark.fillColor   = UIColor(red: 1.0, green: CGFloat.random(in: 0.4...0.9),
                                        blue: 0.1, alpha: 1)
            spark.strokeColor = .clear
            spark.position    = pos
            spark.zPosition   = 8
            addChild(spark)
            let dx = CGFloat.random(in: -60...60)
            let dy = CGFloat.random(in: -60...60)
            spark.run(.sequence([
                .group([.moveBy(x: dx, y: dy, duration: 0.4), .fadeOut(withDuration: 0.4)]),
                .removeFromParent()
            ]))
        }
        
        // Hit adjacent blocks in blast radius
        let blastR = cell * 1.6
        for entity in entityManager.entities(with: BlockTypeComponent.self) {
            guard let render = entity.component(ofType: RenderComponent.self) else { continue }
            let dist = hypot(render.node.position.x - pos.x, render.node.position.y - pos.y)
            if dist < blastR && dist > 1 {
                handleBlockHit(node: render.node)
            }
        }
    }
    
    // MARK: - Pickup Collection
    
    func handlePickupCollected(node: SKNode) {
        guard let entity = entityManager.entity(forNode: node) else { return }
        guard let consumable = entity.component(ofType: ConsumableComponent.self) else { return }
        
        // Deregister and remove physics so the same pickup can't be collected twice
        entityManager.untrack(entity)
        node.physicsBody = nil
        node.removeFromParent()
        
        switch consumable.pickupType {
        case .ammo:
            let previousCount = ballCount
            ballCount += 1
            
            HapticManager.shared.play(.medium)
            
            animateAmmoGain(
                from: node.position,
                oldCount: previousCount,
                newCount: ballCount
            )
            
            refreshHUD()
            
            floatLabel(
                "+1",
                at: node.position,
                color: UIColor(
                    red: 0.45,
                    green: 0.72,
                    blue: 1.0,
                    alpha: 1
                )
            )
        case .portalToken:
            portalCharges += 1
            refreshHUD()
            HapticManager.shared.play(.heavy)
            floatLabel("⬡ portal!", at: node.position, color: UIColor(red: 0.72, green: 0.50, blue: 1.0, alpha: 1))
            
        }
    }
    
}
