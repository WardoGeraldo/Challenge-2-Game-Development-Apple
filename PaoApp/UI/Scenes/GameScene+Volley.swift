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

    

    

    

    
    


    

    
    // MARK: - Volley Fire
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
        
        // Fire all balls with staggered delay
        for i in 0..<volleyTotal {
            run(.sequence([
                .wait(forDuration: TimeInterval(i) * GameConstants.shootGap),
                .run { [weak self] in self?.fireOneBall() }
            ]))
        }
    }
    
    func fireOneBall() {
        guard let texture = bakpaoNode?.texture else { return }

        let node = BallNode(texture: texture, radius: GameConstants.ballRadius)
        node.position = CGPoint(x: shootX, y: shootY)
        let entity = BallEntity(node: node)
        entityManager.add(entity)

        node.physicsBody?.velocity = CGVector(
            dx: cos(shotAngle) * GameConstants.ballSpeed,
            dy: sin(shotAngle) * GameConstants.ballSpeed
        )
    }
    
    // MARK: - Ball Landing
    func ballLanded(entity: GKEntity, ball: SKNode) {
        
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
    
    // MARK: - End Volley
    func endVolley() {
        
        // Cari posisi landing paling ramai
        shootX = calculateBestLandingX()
        updateAmmoContainerPosition()
        
        stateMachine.enter(GameTurnEndState.self)
                
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
                    self?.stateMachine.enter(GameAimState.self)
                }
        ]))
    }
    
}
