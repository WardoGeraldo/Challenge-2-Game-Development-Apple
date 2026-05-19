//
//  GameScenePart3.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 19/05/26.
//
import Foundation
import SpriteKit
import GameplayKit
import UIKit
extension GameScene {
    // MARK: - Background
    func buildBackground() {
        backgroundColor = .black
        if let bg = backgroundNode?.copy() as? SKSpriteNode {
            
            bg.position = CGPoint(
                x: frame.midX,
                y: frame.midY
            )
            
            bg.size = frame.size
            
            bg.zPosition = -100
            
            addChild(bg)
        }
  
        if let grid = bgCheckeredNode?.copy() as? SKSpriteNode {
            self.bgCheckeredNode = grid
        
            let textureSize = grid.texture?.size() ?? CGSize(
                width: 100,
                height: 100
            )
            let targetWidth = frame.width * 0.94
            let aspectRatio =
            textureSize.height / textureSize.width
            
            let targetHeight =
            targetWidth * aspectRatio
            
            gridW = targetWidth
            gridH = targetHeight
            
            grid.anchorPoint = CGPoint(x: 0, y: 0)
            grid.position = gridOrigin
            grid.size = CGSize(
                width: gridW,
                height: gridH
            )
            grid.zPosition = 0
            grid.name = "grid"
            
            addChild(grid)
        }
    }

    
    

    func updateAmmoIcons() {
        ammoContainer.removeAllChildren()

        // Kalau lagi volley → jangan tampilkan ammo bawah
        if isVolleyActive {
            countLabel.text = ""
            return
        }

        let size: CGFloat = GameConstants.ballRadius * 1.75
        let maxWidth: CGFloat = 120
        let spacing: CGFloat
       
        if ballCount <= 5 {
            spacing = size * 0.72
        } else if ballCount <= 10 {
            spacing = size * 0.48
        } else {
            spacing = size * 0.28
        }

        let totalWidth = CGFloat(max(ballCount - 1, 0)) * spacing
        let clampedWidth = min(totalWidth, maxWidth)
        let finalSpacing: CGFloat

        if ballCount > 1 {
            finalSpacing = min(
                spacing,
                clampedWidth / CGFloat(ballCount - 1)
            )
        } else {
            finalSpacing = spacing
        }

        let startX = CGFloat(0)

        for i in 0..<ballCount {

            guard let sprite = bakpaoNode?.copy() as? SKSpriteNode else {
                continue
            }

            sprite.size = CGSize(width: size, height: size)

            sprite.position = CGPoint(
                x: startX + CGFloat(i) * finalSpacing,
                y: CGFloat.random(in: -2...2)
            )

            sprite.zRotation = CGFloat.random(in: -0.18...0.18)

            sprite.zPosition = CGFloat(i)

            let scale = CGFloat.random(in: 0.94...1.04)
            sprite.setScale(scale)

            ammoContainer.addChild(sprite)

            let delay = Double(i) * 0.05

            let moveUp = SKAction.moveBy(
                x: 0,
                y: CGFloat.random(in: 2...5),
                duration: Double.random(in: 0.6...1.0)
            )

            moveUp.timingMode = .easeInEaseOut

            let moveDown = moveUp.reversed()

            let floatAnim = SKAction.sequence([
                .wait(forDuration: delay),
                .sequence([moveUp, moveDown])
            ])

            sprite.run(.repeatForever(floatAnim))
        }

        countLabel.text = ""
    }

}
