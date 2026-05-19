//
//  GameScenePart2.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 19/05/26.
//

import Foundation
import SpriteKit
import GameplayKit
import UIKit
extension GameScene {
    // MARK: - Walls (left, right, top — no floor so balls can land)
    func buildWalls() {

        let left   = gridOrigin.x
        let right  = gridOrigin.x + gridW
        let bottom = gridOrigin.y
        let top    = gridOrigin.y + gridH

        let edges: [(CGPoint, CGPoint)] = [

            // LEFT
            (CGPoint(x: left, y: bottom),
             CGPoint(x: left, y: top)),

            // RIGHT
            (CGPoint(x: right, y: bottom),
             CGPoint(x: right, y: top)),

            // TOP
            (CGPoint(x: left, y: top),
             CGPoint(x: right, y: top))
        ]

        for (a, b) in edges {
            let wall = SKNode()
            wall.physicsBody = SKPhysicsBody(edgeFrom: a, to: b)
            wall.physicsBody?.friction = 0
            wall.physicsBody?.restitution = 1
            wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
            wall.physicsBody?.collisionBitMask = PhysicsCategory.ball
            wall.physicsBody?.contactTestBitMask = PhysicsCategory.ball
            addChild(wall)
        }
    }
    
    // MARK: - HUD
    func buildHUD() {
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

        refreshHUD()
    }

    
    func refreshHUD() {
        updateAmmoIcons()
        ammoContainer.run(.sequence([
            .scale(to: 1.12, duration: 0.06),
            .scale(to: 1.0, duration: 0.08)
        ]))
    }
}
