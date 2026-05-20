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
    // MARK: - HUD Build
    func buildHUD() {
        // Score label — displayed above the grid, centered
        scoreLabel = SKLabelNode()
        scoreLabel.attributedText = NSAttributedString(string: "0", attributes: scoreAttributes())
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: gridOrigin.x + gridW / 2, y: gridOrigin.y + gridH + 65)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)

        ammoContainer.zPosition = 10
        ammoContainer.name = "ui"
        addChild(ammoContainer)

        ammoContainer.position = CGPoint(
            x: shootX - 24,
            y: shootY
        )

        // Label jumlah bakpao
        countLabel = SKLabelNode(fontNamed: GameConstants.fontName)
        countLabel.fontSize = 18
        countLabel.fontColor = UIColor.white
        countLabel.horizontalAlignmentMode = .left
        countLabel.verticalAlignmentMode = .center
        countLabel.zPosition = 11
        addChild(countLabel)

        // Portal label
        portalLabel = SKLabelNode(fontNamed: GameConstants.fontName)
        portalLabel.fontSize = 14
        portalLabel.fontColor = UIColor(
            red: 0.72,
            green: 0.50,
            blue: 1.0,
            alpha: 1
        )

        portalLabel.horizontalAlignmentMode = .left
        portalLabel.verticalAlignmentMode = .center
        portalLabel.position = CGPoint(
            x: gridOrigin.x + 160,
            y: shootY
        )

        portalLabel.zPosition = 10
        addChild(portalLabel)

        // Turn label
        turnLabel = SKLabelNode(fontNamed: GameConstants.fontName)
        turnLabel.fontSize = 13
        turnLabel.fontColor = UIColor(white: 0.5, alpha: 1)

        turnLabel.horizontalAlignmentMode = .right
        turnLabel.verticalAlignmentMode = .center

        turnLabel.position = CGPoint(
            x: gridOrigin.x + gridW - 6,
            y: shootY
        )

        turnLabel.zPosition = 10
        addChild(turnLabel)
        
        ammoCountLabel = SKLabelNode()
          ammoCountLabel.attributedText = NSAttributedString(
              string: "x\(ballCount)",
              attributes: ammoCountAttributes()
          )
          ammoCountLabel.horizontalAlignmentMode = .center
          ammoCountLabel.verticalAlignmentMode   = .center
          ammoCountLabel.position  = CGPoint(x: 25, y: 0) // center of bakpaoCountFrameNode
          ammoCountLabel.zPosition = 9
          bakpaoCountFrameNode?.addChild(ammoCountLabel)

        refreshHUD()
    }

    // MARK: - HUD Refresh
    func refreshHUD() {
        scoreLabel.attributedText = NSAttributedString(
            string: "\(ScoreManager.shared.currentScore)",
            attributes: scoreAttributes()
        )
        updateAmmoIcons()
        ammoContainer.run(.sequence([
            .scale(to: 1.12, duration: 0.06),
            .scale(to: 1.0, duration: 0.08)
        ]))
        ammoCountLabel.attributedText = NSAttributedString(
            string: "x \(ballCount)",
            attributes: ammoCountAttributes()
        )
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
    
    // MARK: - Ammo Gain Animation
    // Flies a bakpao icon from the pickup position to its slot in the ammo container.
    func animateAmmoGain(
        from worldPosition: CGPoint,
        oldCount: Int,
        newCount: Int
    ) {

        // Ukuran pickup asli
        let pickupSize = cell * 0.82

        // Ukuran HUD
        let hudSize = GameConstants.ballRadius * 1.75

        // Spawn di scene langsung
        guard let flying = collectBakpaoNode?.copy() as? SKSpriteNode else {
            return
        }

        flying.size = CGSize(
            width: pickupSize,
            height: pickupSize
        )

        flying.position = worldPosition
        flying.zPosition = 999

        addChild(flying)

        // ===== TARGET HUD POSITION =====

        let spacing: CGFloat

        if newCount <= 5 {
            spacing = hudSize * 0.72
        } else if newCount <= 10 {
            spacing = hudSize * 0.48
        } else {
            spacing = hudSize * 0.28
        }

        let maxWidth: CGFloat = 120

        let finalSpacing: CGFloat

        if newCount > 1 {
            finalSpacing = min(
                spacing,
                maxWidth / CGFloat(newCount - 1)
            )
        } else {
            finalSpacing = spacing
        }

        // Convert target HUD position → scene coordinate
        let localTarget = CGPoint(
            x: CGFloat(newCount - 1) * finalSpacing,
            y: CGFloat.random(in: -2...2)
        )

        let targetPos = ammoContainer.convert(
            localTarget,
            to: self
        )

        // ===== FALL DOWN =====

        let drop = SKAction.moveBy(
            x: 0,
            y: -140,
            duration: 0.75
        )

        drop.timingMode = .easeIn

        // Squash saat jatuh
        let squash = SKAction.sequence([

            .group([
                .scaleX(to: 1.18, duration: 0.10),
                .scaleY(to: 0.78, duration: 0.10)
            ]),

            .group([
                .scaleX(to: 1.0, duration: 0.12),
                .scaleY(to: 1.0, duration: 0.12)
            ])
        ])

        // ===== FLY TO HUD =====

        let fly = SKAction.move(
            to: targetPos,
            duration: 0.55
        )

        fly.timingMode = .easeInEaseOut

        let shrink = SKAction.resize(
            toWidth: hudSize,
            height: hudSize,
            duration: 0.55
        )

        shrink.timingMode = .easeOut

        let rotate = SKAction.rotate(
            byAngle: CGFloat.random(in: -0.8...0.8),
            duration: 0.55
        )

        // ===== POP =====

        let pop = SKAction.sequence([
            .scale(to: 1.2, duration: 0.08),
            .scale(to: 1.0, duration: 0.12)
        ])

        flying.run(.sequence([

            // Jatuh dulu
            .group([
                drop,
                squash
            ]),

            // Pause biar kerasa
            .wait(forDuration: 0.12),

            // Terbang ke HUD
            .group([
                fly,
                shrink,
                rotate
            ]),

            // Pop masuk HUD
            pop,

            .run { [weak self] in
                self?.updateAmmoIcons()
            },

            .removeFromParent()
        ]))
    }
    
    func updateAmmoContainerPosition(animated: Bool = true) {

        let target = CGPoint(
            x: shootX,
            y: shootY - 4
        )

        if animated {

            let move = SKAction.move(
                to: target,
                duration: 0.22
            )

            move.timingMode = .easeInEaseOut

            ammoContainer.run(move)

        } else {

            ammoContainer.position = target
        }
    }
    
    // MARK: - Feedback Labels
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
    private func scoreAttributes() -> [NSAttributedString.Key: Any] {
          return [
              .font: UIFont(name: "Melon-Pop", size: 75) ?? UIFont.systemFont(ofSize: 75),
              .foregroundColor: UIColor(red: 254/255, green: 238/255, blue: 208/255, alpha: 1),
              .strokeColor:     UIColor(red:92/255, green:53/255, blue:22/255,  alpha: 1),
              .strokeWidth:     -5
          ]
      }
    private func ammoCountAttributes() -> [NSAttributedString.Key: Any] {
          return [
              .font: UIFont(name: "Melon-Pop", size: 30) ?? UIFont.systemFont(ofSize: 30),
              .foregroundColor: UIColor(red: 242/255, green: 211/255, blue: 141/255, alpha: 1),
              .strokeColor:     UIColor(red:92/255, green:53/255, blue:22/255,  alpha: 1),
              .strokeWidth:     -5
          ]
      }
}
