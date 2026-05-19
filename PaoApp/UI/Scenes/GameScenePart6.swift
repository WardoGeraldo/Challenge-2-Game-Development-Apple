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
    // MARK: - Physics Contacts
    
//    func didBegin(_ contact: SKPhysicsContact) {
//        let a = contact.bodyA.categoryBitMask
//        let b = contact.bodyB.categoryBitMask
//        let pair = a | b
//        
//        // Ball ↔ Block
//        if pair == PhysicsCategory.ball | PhysicsCategory.block {
//            guard let ballNode  = (a == PhysicsCategory.ball  ? contact.bodyA : contact.bodyB).node,
//                  let blockNode = (a == PhysicsCategory.block ? contact.bodyA : contact.bodyB).node
//            else { return }
//            collisionSystem.enqueue(CollisionEvent(ballNode: ballNode, otherNode: blockNode, isBlock: true))
//        }
//        
//        // Ball ↔ Pickup
//        if pair == PhysicsCategory.ball | PhysicsCategory.pickup {
//            guard let ballNode   = (a == PhysicsCategory.ball   ? contact.bodyA : contact.bodyB).node,
//                  let pickupNode = (a == PhysicsCategory.pickup ? contact.bodyA : contact.bodyB).node
//            else { return }
//            collisionSystem.enqueue(CollisionEvent(ballNode: ballNode, otherNode: pickupNode, isBlock: false))
//        }
//    }
    
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
    
    func floatLabel(_ text: String, at pos: CGPoint, color: UIColor) {
        let lbl = SKLabelNode(fontNamed: GameConstants.fontName)
        lbl.text      = text
        lbl.fontSize  = 18
        lbl.fontColor = color
        lbl.position  = pos
        lbl.zPosition = 12
        addChild(lbl)
        lbl.run(.sequence([
            .group([
                .moveBy(x: 0, y: 34, duration: 0.55),
                .sequence([.wait(forDuration: 0.25), .fadeOut(withDuration: 0.30)])
            ]),
            .removeFromParent()
        ]))
    }
    
    // MARK: - Ball Landing
    func ballLanded(entity: GKEntity, ball: SKSpriteNode) {
        
        // Clamp posisi landing
        let lo = gridOrigin.x + GameConstants.ballRadius + gap
        let hi = gridOrigin.x + gridW - GameConstants.ballRadius - gap
        
        let clampedX = Swift.min(
            Swift.max(ball.position.x, lo),
            hi
        )
        
        landedPositions.append(clampedX)
        
        // Stop physics
        ball.physicsBody?.velocity = .zero
        ball.physicsBody = nil
        
        entityManager.untrack(entity)
        
        // Snap ke floor
        ball.position = CGPoint(
            x: clampedX,
            y: shootY
        )
        
        // Simpan node
        landedBallNodes.append(ball)
        
        // Idle floating kecil
        let float = SKAction.sequence([
            .moveBy(x: 0, y: 2, duration: 0.45),
            .moveBy(x: 0, y: -2, duration: 0.45)
        ])
        
        ball.run(
            .repeatForever(float),
            withKey: "idleFloat"
        )
        
        volleyLanded += 1
        
        showNextMarker(x: clampedX)
        
        if volleyLanded >= volleyTotal {
            endVolley()
        }
    }
    
    func showNextMarker(x: CGFloat) {
        
        nextMarker?.removeFromParent()
        
        let dot = SKShapeNode(
            circleOfRadius: GameConstants.ballRadius * 0.7
        )
        
        dot.fillColor = UIColor(
            red: 0.45,
            green: 0.72,
            blue: 1.0,
            alpha: 0.25
        )
        
        dot.strokeColor = UIColor(
            red: 0.45,
            green: 0.72,
            blue: 1.0,
            alpha: 0.65
        )
        
        dot.lineWidth = 1.5
        
        dot.position = CGPoint(
            x: x,
            y: shootY
        )
        
        dot.zPosition = 4
        dot.name = "ui"
        
        addChild(dot)
        
        nextMarker = dot
    }
    
    func calculateBestLandingX() -> CGFloat {
        
        guard !landedPositions.isEmpty else {
            return frame.midX
        }
        
        let bucketSize: CGFloat = 40
        
        var buckets: [Int: [CGFloat]] = [:]
        
        for x in landedPositions {
            
            let key = Int(x / bucketSize)
            
            buckets[key, default: []].append(x)
        }
        
        // Bucket terbanyak
        let best = buckets.max {
            $0.value.count < $1.value.count
        }
        
        guard let values = best?.value else {
            return frame.midX
        }
        
        // Average position
        let avg = values.reduce(0, +) / CGFloat(values.count)
        
        // Clamp screen
        let lo = gridOrigin.x + 30
        let hi = gridOrigin.x + gridW - 30
        
        return min(max(avg, lo), hi)
    }
    
    
    func repositionLandedBallsAroundPlayer() {
        
        guard !landedBallNodes.isEmpty else { return }
        
        // Dynamic spacing
        let spacing: CGFloat
        
        if landedBallNodes.count <= 5 {
            spacing = 16
        } else if landedBallNodes.count <= 12 {
            spacing = 12
        } else {
            spacing = 8
        }
        
        // Total width
        let totalWidth =
        CGFloat(landedBallNodes.count - 1) * spacing
        
        // Clamp supaya ga keluar layar
        let minX = gridOrigin.x + 20
        let maxX = gridOrigin.x + gridW - totalWidth - 20
        
        let startX = min(
            max(shootX - totalWidth / 2, minX),
            maxX
        )
        
        for (index, ball) in landedBallNodes.enumerated() {
            
            ball.removeAction(forKey: "idleFloat")
            
            let target = CGPoint(
                x: startX + CGFloat(index) * spacing,
                y: shootY
            )
            
            let move = SKAction.move(
                to: target,
                duration: 0.32
            )
            
            move.timingMode = .easeInEaseOut
            
            let bounce = SKAction.sequence([
                .moveBy(x: 0, y: 4, duration: 0.08),
                .moveBy(x: 0, y: -4, duration: 0.10)
            ])
            
            let rotate = SKAction.rotate(
                toAngle: CGFloat.random(in: -0.15...0.15),
                duration: 0.2
            )
            
            ball.run(.group([
                .sequence([move, bounce]),
                rotate
            ]))
        }
    }
    
    // MARK: - End Volley / Advance Board
    func endVolley() {
        
        // Cari posisi landing paling ramai
        shootX = calculateBestLandingX()
        updateAmmoContainerPosition()
        
        stateMachine.enter(GameTurnEndState.self)
        
        clearPortalRings()
        
        nextMarker?.removeFromParent()
        nextMarker = nil
        
        // Kumpulkan bakpao ke player baru
        repositionLandedBallsAroundPlayer()
        
        // Delay supaya animasi kumpul selesai
        run(.sequence([
            
            .wait(forDuration: 0.4),
            
                .run { [weak self] in
                    
                    guard let self else { return }
                    
                    for ball in self.landedBallNodes {
                        
                        ball.run(.sequence([
                            
                            .group([
                                .fadeOut(withDuration: 0.12),
                                .scale(to: 0.7, duration: 0.12)
                            ]),
                            
                                .removeFromParent()
                        ]))
                    }
                    
                    self.landedBallNodes.removeAll()
                }
        ]))
        
        turnNumber += 1
        
        // Delay sedikit supaya visual lebih smooth
        run(.sequence([
            
            .wait(forDuration: 0.12),
            
                .run { [weak self] in
                    
                    guard let self else { return }
                    
                    self.isVolleyActive = false
                    self.refreshHUD()
                    self.placeShooterMarker()
                    self.advanceBoard()
                }
        ]))
        
        // Back to aiming
        run(.sequence([
            
            .wait(forDuration: 0.62),
            
                .run { [weak self] in
                    self?.stateMachine.enter(GameAimingState.self)
                }
        ]))
    }
    
    // Moves all blocks/pickups down one row; removes anything that would land at/below
    // the shooter row. Spawns a fresh row at the top after 0.08s.
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
            } else {
                node.run(moveDown)
            }
        }
        
        run(.sequence([
            .wait(forDuration: 0.08),
            .run { [weak self] in self?.spawnRow(0) }
        ]))
    }
    func clampToPlayArea(_ point: CGPoint) -> CGPoint {
        
        let minX = gridOrigin.x + playAreaInset
        let maxX = gridOrigin.x + gridW - playAreaInset
        let minY = gridOrigin.y + playAreaInset
        let maxY = gridOrigin.y + gridH - playAreaInset
        
        return CGPoint(
            x: min(max(point.x, minX), maxX),
            y: min(max(point.y, minY), maxY)
        )
    }
}

