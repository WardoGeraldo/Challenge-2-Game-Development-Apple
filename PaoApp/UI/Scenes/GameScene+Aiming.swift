//
//  GameScenePart4.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 19/05/26.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

extension GameScene {

    // MARK: - Gesture Setup
    func addPanGesture(to view: SKView) {
        view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        )
    }
    
    @objc func onPan(_ g: UIPanGestureRecognizer) {
        
        guard stateMachine.currentState is GameAimState else { return }
        
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
    
    // MARK: - Aim Visualization
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

    // MARK: - Helpers
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
    
}
