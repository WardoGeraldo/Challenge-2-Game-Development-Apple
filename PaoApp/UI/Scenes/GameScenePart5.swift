//
//  GameScenePart5.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 19/05/26.
//

import Foundation
import UIKit
import GameplayKit
import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard
            let nodeA = contact.bodyA.node,
            let nodeB = contact.bodyB.node,
            let entityA = entityManager.entity(forNode: nodeA),
            let entityB = entityManager.entity(forNode: nodeB)
        else { return }
        
        guard
            let physicsComponentA = entityA.component(
                ofType: PhysicsComponent.self
            )
        else {
            return
        }
        
        physicsComponentA.contactQueue.append(
            contact
        )
    }
    
    // MARK: - Gesture (Aiming)
    func addBlockEntity(at pos: CGPoint, type: BlockType, hp: Int) {
        let node = BlockNode.make(type: type, hp: hp, ballCount: ballCount, cell: cell)
        node.position = pos
        
        // Detach physics during the 0.35s spawn animation — prevents the ball
        // from bouncing off a block that's still at 20% scale (invisible).
        let spawnBody    = node.physicsBody
        node.physicsBody = nil
        
        let entity = BlockEntity(type: .normal, health: 5, ballCount: 3, cell: 3.0)
        entityManager.add(entity)
        
        // Re-attach physics after spawn animation completes
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
        case .portalToken:
            let n = PortalPickupNode(cell: cell)
            n.position = pos
            node = n
        }
        let entity = ItemBallEntity(node: node, type: type)
        entityManager.add(entity)
    }
    
    func addPanGesture(to view: SKView) {
        view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        )
    }
    
    func updateAimDots(angle: CGFloat) {
        guard let gridNode = bgCheckeredNode else { return }
        
        let gridFrame = gridNode.frame
        removeAimDots()
        
        let start = CGPoint(
            x: min(max(shootX, playAreaRect.minX), playAreaRect.maxX),
            y: min(max(shootY, playAreaRect.minY), playAreaRect.maxY)
        )
        
        let direction = CGVector(
            dx: cos(angle),
            dy: sin(angle)
        )
        
        // Maximum ray length
        let maxDistance: CGFloat = max(gridW, gridH)
        
        let end = CGPoint(
            x: start.x + direction.dx * maxDistance,
            y: start.y + direction.dy * maxDistance
        )
        
        // Default target
        var targetPoint = end
        
        let minX = gridFrame.minX
        let maxX = gridFrame.maxX
        let minY = gridFrame.minY
        let maxY = gridFrame.maxY
        
        targetPoint.x = min(max(targetPoint.x, playAreaRect.minX), playAreaRect.maxX)
        targetPoint.y = min(max(targetPoint.y, playAreaRect.minY), playAreaRect.maxY)
        
        // ===== Raycast =====
        
        physicsWorld.enumerateBodies(
            alongRayStart: start,
            end: end
        ) { body, point, normal, stop in
            
            guard let node = body.node else { return }
            
            // Ignore balls/player/pickups/ui
            if node.name == "ball"
                || node.name == "player"
                || node.name == "pickup_ammo"
                || node.name == "pickup_portal"
                || node.name == "ui" {
                
                return
            }
            
            // Only stop on wall/block
            let category = body.categoryBitMask
            
            let validHit =
            category == PhysicsCategory.wall
            || category == PhysicsCategory.block
            
            if validHit {
                
                targetPoint = point
                
                stop.pointee = true
            }
            targetPoint.x = min(max(targetPoint.x, minX), maxX)
            targetPoint.y = min(max(targetPoint.y, minY), maxY)
        }
        
        // ===== Distance =====
        
        let totalDistance = hypot(
            targetPoint.x - start.x,
            targetPoint.y - start.y
        )
        
        let spacing: CGFloat = 24
        
        let count = max(1, Int(totalDistance / spacing))
        
        let arrowSize: CGFloat = 18
        
        let dotCount = max(
            1,
            Int(totalDistance / spacing)
        )
        
        // ===== DOTS =====
        // Hanya sampai sebelum terakhir
        for i in 0..<(dotCount - 1) {
            
            let progress = CGFloat(i) / CGFloat(max(dotCount - 1, 1))
            
            let pos = CGPoint(
                x: start.x + (targetPoint.x - start.x) * progress,
                y: start.y + (targetPoint.y - start.y) * progress
            )
            
            let size = max(
                4,
                10 - CGFloat(i) * 0.15
            )
            
            let dot = SKShapeNode(
                circleOfRadius: size
            )
            
            dot.fillColor = UIColor.white.withAlphaComponent(
                max(0.25, 0.92 - CGFloat(i) * 0.03)
            )
            
            dot.strokeColor = .clear
            
            dot.position = pos
            
            dot.zPosition = 20
            
            addChild(dot)
            
            aimDots.append(dot)
        }
        
        //
        // ===== ROUNDED ARROW =====
        // Posisi menggantikan dot terakhir
        //
        
        let arrowProgress = CGFloat(dotCount - 1) / CGFloat(max(dotCount - 1, 1))
        
        let arrowOffset = arrowSize * 0.9
        
        let arrowPos = CGPoint(
            x: start.x + (targetPoint.x - start.x) * arrowProgress,
            y: start.y + (targetPoint.y - start.y) * arrowProgress
        )
        
        let arrow = SKShapeNode()
        
        let arrowAngle = atan2(
            direction.dy,
            direction.dx
        )
        
        // Rounded triangle points
        let tip = CGPoint(
            x: cos(arrowAngle) * arrowSize,
            y: sin(arrowAngle) * arrowSize
        )
        
        let left = CGPoint(
            x: cos(arrowAngle + .pi * 0.82) * arrowSize * 0.72,
            y: sin(arrowAngle + .pi * 0.82) * arrowSize * 0.72
        )
        
        let right = CGPoint(
            x: cos(arrowAngle - .pi * 0.82) * arrowSize * 0.72,
            y: sin(arrowAngle - .pi * 0.82) * arrowSize * 0.72
        )
        
        // Smooth rounded path
        let path = UIBezierPath()
        
        path.move(to: tip)
        
        path.addQuadCurve(
            to: left,
            controlPoint: CGPoint(
                x: (tip.x + left.x) / 2,
                y: (tip.y + left.y) / 2
            )
        )
        
        path.addQuadCurve(
            to: right,
            controlPoint: CGPoint(
                x: 0,
                y: 0
            )
        )
        
        path.addQuadCurve(
            to: tip,
            controlPoint: CGPoint(
                x: (tip.x + right.x) / 2,
                y: (tip.y + right.y) / 2
            )
        )
        
        path.close()
        
        arrow.path = path.cgPath
        
        arrow.fillColor = UIColor.white.withAlphaComponent(0.96)
        
        arrow.strokeColor = .clear
        
        arrow.position = clampToPlayArea(arrowPos)
        
        arrow.zPosition = 21
        
        addChild(arrow)
        
        aimArrow = arrow
    }
    
    @objc func onPan(_ g: UIPanGestureRecognizer) {
        
        guard stateMachine.currentState is GameAimingState else { return }
        
        let raw = g.translation(in: view)
        
        let angle = clampAngle(
            dx: raw.x,
            dy: -raw.y
        )
        
        switch g.state {
            
        case .began, .changed:
            
            updateAimDots(angle: angle)
            
            // Simpan angle ke player component
            playerEntity?
                .component(ofType: ControlComponent.self)?
                .pointTo = CGPoint(x: raw.x, y: raw.y)
            
        case .ended, .cancelled:
            
            removeAimDots()
            
            shotAngle = angle
            
            startVolley(angle: angle)
            
        default:
            break
        }
    }
    func removeAimDots() {
        
        aimArrow?.removeFromParent()
        aimArrow = nil
        
        for dot in aimDots {
            dot.removeFromParent()
        }
        
        aimDots.removeAll()
    }
    
    // Clamps angle to at least 8° from horizontal so balls always move upward
    func clampAngle(dx: CGFloat, dy: CGFloat) -> CGFloat {
        let min8 = CGFloat(8) * .pi / 180
        var a    = atan2(dy, dx)
        if dy <= 0 { a = dx >= 0 ? min8 : .pi - min8 }
        else       { a = Swift.min(Swift.max(a, min8), .pi - min8) }
        return a
    }
    
    // MARK: - Volley
    
    func startVolley(angle: CGFloat) {
        isVolleyActive = true
        refreshHUD()
        shotAngle    = angle
        volleyTotal  = ballCount
        volleyLanded = 0
        //        firstLandX   = nil
        landedPositions.removeAll()
        landedBallNodes.removeAll()
        
        stateMachine.enter(GameFlyingState.self)
        
        // Activate portal warp if a charge is available
        if portalCharges > 0 {
            portalCharges -= 1
            refreshHUD()
            activatePortalVolley()
        }
        
        // Fire all balls with staggered delay
        for i in 0..<volleyTotal {
            run(.sequence([
                .wait(forDuration: TimeInterval(i) * GameConstants.shootGap),
                .run { [weak self] in self?.fireOneBall() }
            ]))
        }
    }
    
    func fireOneBall() {
        //        let node = BallNode(radius: GameConstants.ballRadius)
        guard let texture = bakpaoNode?.texture else { return }
        
        let node = BallNode(scale: 1.0)
        node.position = CGPoint(x: shootX, y: shootY)
        let entity    = BallEntity(node: node)
        entityManager.add(entity)
        
        // Apply velocity
        node.physicsBody?.velocity = CGVector(
            dx: cos(shotAngle) * GameConstants.ballSpeed,
            dy: sin(shotAngle) * GameConstants.ballSpeed
        )
    }
    
    // MARK: - Portal Volley
    
    // Places entry (top half) and exit (bottom half) warp rings.
    // Balls passing through the entry ring are teleported to the exit band in update().
    func activatePortalVolley() {
        var occupied = Set<String>()
        entityManager.entities(with: BlockTypeComponent.self).forEach {
            guard let render = $0.component(ofType: RenderComponent.self) else { return }
            let col = Int(round((render.node.position.x - gridOrigin.x - gap - cell/2) / step))
            let row = Int(round((gridOrigin.y + gridH - gap - cell/2 - render.node.position.y) / step))
            occupied.insert("\(col),\(row)")
        }
        entityManager.entities(with: ConsumableComponent.self).forEach {
            guard let render = $0.component(ofType: RenderComponent.self) else { return }
            let col = Int(round((render.node.position.x - gridOrigin.x - gap - cell/2) / step))
            let row = Int(round((gridOrigin.y + gridH - gap - cell/2 - render.node.position.y) / step))
            occupied.insert("\(col),\(row)")
        }
        
        func emptyCell(inRows range: ClosedRange<Int>) -> CGPoint? {
            var candidates: [CGPoint] = []
            for row in range {
                for col in 0..<GameConstants.cols {
                    if !occupied.contains("\(col),\(row)") {
                        candidates.append(cellCenter(col: col, row: row))
                    }
                }
            }
            return candidates.randomElement()
        }
        
        guard let topPos    = emptyCell(inRows: 0...3),
              let bottomPos = emptyCell(inRows: 4...7) else { return }
        
        portalEntryY = topPos.y
        portalExitY  = bottomPos.y
        
        let pairs: [(CGPoint, UIColor)] = [
            (topPos,    UIColor(red: 0.72, green: 0.50, blue: 1.0, alpha: 0.9)),
            (bottomPos, UIColor(red: 0.50, green: 0.85, blue: 0.72, alpha: 0.9))
        ]
        
        for (pos, color) in pairs {
            let ring = SKShapeNode(circleOfRadius: cell * 0.40)
            ring.fillColor   = color.withAlphaComponent(0.13)
            ring.strokeColor = color
            ring.lineWidth   = 2.5
            ring.position    = pos
            ring.zPosition   = 8
            ring.name        = "portalRing"
            
            let inner = SKShapeNode(circleOfRadius: cell * 0.22)
            inner.fillColor   = .clear
            inner.strokeColor = color.withAlphaComponent(0.55)
            inner.lineWidth   = 1.2
            inner.run(.repeatForever(.rotate(byAngle: -.pi * 2, duration: 1.2)))
            ring.addChild(inner)
            ring.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 2.0)))
            addChild(ring)
        }
        
        // Safety cleanup after 12s in case volley runs long
        run(.sequence([
            .wait(forDuration: 12),
            .run { [weak self] in self?.clearPortalRings() }
        ]))
    }
    
    func clearPortalRings() {
        enumerateChildNodes(withName: "portalRing") { n, _ in n.removeFromParent() }
        portalEntryY = nil
        portalExitY  = nil
    }
    
    // MARK: - update
    
    override func update(_ currentTime: TimeInterval) {
        let dt: CGFloat = lastDT == 0
        ? 1 / 60.0
        : CGFloat(min(currentTime - lastDT, 1 / 30.0))
        lastDT = currentTime
        
        // Rover movement always runs (even during aiming)
        movementSystem.update(
            deltaTime: dt,
            entityManager: entityManager,
            cell: cell,
            gap: gap,
            gridOriginX: gridOrigin.x,
            gridWidth: gridW
        )
        
        // Process queued collision events
//        TODO: benerno cuk
//        for event in collisionSystem.dequeueAll() {
//            if event.isBlock {
//                handleBlockHit(node: event.otherNode)
//            } else {
//                handlePickupCollected(node: event.otherNode)
//            }
//        }
        
        guard stateMachine.currentState is GameFlyingState else { return }
        
        // Ball position updates
        for entity in entityManager.entities(with: VelocityComponent.self) {
            guard let velComp = entity.component(ofType: VelocityComponent.self),
                  let render  = entity.component(ofType: RenderComponent.self),
                  let sprite  = render.node as? SKSpriteNode,
                  let body    = sprite.physicsBody,
                  body.isDynamic else { continue }
            
            // Accumulate flight time and force-land any ball stuck for too long.
            // This is the hard backstop against infinite horizontal bounce loops.
            velComp.flightTime += dt
            if velComp.flightTime > 10 {
                ballLanded(entity: entity, ball: sprite)
                continue
            }
            
            let v = body.velocity
            
            // Track rise above shooter row
            if sprite.position.y > shootY + cell {
                velComp.hasRisen = true
            }
            
            // Detect landing: ball rose and returned to/below the shooter row moving down
            if velComp.hasRisen && sprite.position.y <= shootY && v.dy <= 0 {
                ballLanded(entity: entity, ball: sprite)
                continue
            }
            
            // Portal warp: teleport ball at entry band to exit band
            if let entryY = portalEntryY, let exitY = portalExitY {
                if abs(sprite.position.y - entryY) < cell * 0.4 && v.dy > 0 {
                    sprite.position.y = exitY
                    sprite.run(.sequence([
                        .scale(to: 1.5, duration: 0.05),
                        .scale(to: 1.0, duration: 0.08)
                    ]))
                }
            }
            
            // Gravity only fires when the ball is moving downward or within ~3° of
            // horizontal. Upward-moving balls (vy > threshold) travel in a straight
            // line so low-angle shots feel natural. Stuck horizontal balls accumulate
            // the downward nudge over a few seconds and land on their own.
            let vx  = v.dx
            let rawVY = v.dy
            let vy  = rawVY < GameConstants.ballSpeed * 0.05
            ? rawVY - GameConstants.gravityAccel * dt
            : rawVY
            let spd = hypot(vx, vy)
            if spd > 1 {
                body.velocity = CGVector(
                    dx: vx / spd * GameConstants.ballSpeed,
                    dy: vy / spd * GameConstants.ballSpeed
                )
                sprite.position.x = min(max(sprite.position.x, gridOrigin.x), gridOrigin.x + gridW)
                sprite.position.y = min(max(sprite.position.y, gridOrigin.y), gridOrigin.y + gridH)
            }
        }
    }
    
}
