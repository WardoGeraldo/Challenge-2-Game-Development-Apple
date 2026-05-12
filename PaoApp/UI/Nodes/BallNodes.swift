//
//  BallNodes.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import SpriteKit
import UIKit

// MARK: - BallNode

// Flying bakpao — uses the bakpaoAmmo asset.
// CCD (usesPreciseCollisionDetection) prevents tunnelling through blocks at high speed.
class BallNode: SKSpriteNode {
    init(radius: CGFloat) {
        super.init(
            texture: SKTexture(imageNamed: "bakpaoAmmo"),
            color: .clear,
            size: CGSize(width: radius * 2, height: radius * 2)
        )
        name      = "ball"
        zPosition = 7
        setupPhysics(radius: radius)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics(radius: CGFloat) {
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.friction                      = 0
        body.linearDamping                 = 0
        body.restitution                   = 1
        body.allowsRotation                = false
        body.isDynamic                     = true
        // CCD prevents fast ball from tunnelling through thin blocks or walls
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask               = PhysicsCategory.ball
        body.collisionBitMask              = PhysicsCategory.wall | PhysicsCategory.block
        body.contactTestBitMask            = PhysicsCategory.block | PhysicsCategory.pickup
        physicsBody = body
    }
}

// MARK: - AmmoPickupNode

// Bakpao pickup — same asset as the thrown ball, sized to match the grid cell.
class AmmoPickupNode: SKNode {
    init(cell: CGFloat) {
        super.init()
        let size = cell * 0.82

        let sprite = SKSpriteNode(imageNamed: "bakpaoAmmo")
        sprite.size = CGSize(width: size, height: size)
        addChild(sprite)

        name      = "pickup_ammo"
        zPosition = 3

        let body = SKPhysicsBody(circleOfRadius: size * 0.45)
        body.isDynamic          = false
        body.categoryBitMask    = PhysicsCategory.pickup
        body.collisionBitMask   = 0
        body.contactTestBitMask = PhysicsCategory.ball
        physicsBody = body

        run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 3, duration: 0.6),
            .moveBy(x: 0, y: -3, duration: 0.6)
        ])))
        run(.repeatForever(.sequence([
            .scale(to: 1.08, duration: 0.9),
            .scale(to: 0.94, duration: 0.9)
        ])))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - PortalPickupNode

// Rare purple hexagonal token — next volley gains a mid-air warp
class PortalPickupNode: SKNode {
    init(cell: CGFloat) {
        super.init()
        let size = cell * 0.46

        let hex = SKShapeNode(path: PortalPickupNode.hexagonPath(radius: size))
        hex.fillColor   = UIColor(red: 0.30, green: 0.15, blue: 0.60, alpha: 0.95)
        hex.strokeColor = UIColor(red: 0.72, green: 0.50, blue: 1.00, alpha: 0.90)
        hex.lineWidth   = 2
        addChild(hex)

        // Inner spinning ring
        let ring = SKShapeNode(circleOfRadius: size * 0.55)
        ring.fillColor   = .clear
        ring.strokeColor = UIColor(red: 0.80, green: 0.65, blue: 1.0, alpha: 0.70)
        ring.lineWidth   = 1.5
        ring.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 2.4)))
        hex.addChild(ring)

        let glyph = SKLabelNode(text: "⬡")
        glyph.fontSize              = size * 1.1
        glyph.fontColor             = UIColor(red: 0.85, green: 0.72, blue: 1.0, alpha: 1)
        glyph.verticalAlignmentMode = .center
        hex.addChild(glyph)

        name      = "pickup_portal"
        zPosition = 3

        let body = SKPhysicsBody(circleOfRadius: size)
        body.isDynamic          = false
        body.categoryBitMask    = PhysicsCategory.pickup
        body.collisionBitMask   = 0
        body.contactTestBitMask = PhysicsCategory.ball
        physicsBody = body

        run(.repeatForever(.sequence([
            .group([
                .sequence([.moveBy(x: 0, y: 4, duration: 0.8), .moveBy(x: 0, y: -4, duration: 0.8)]),
                .sequence([.scale(to: 1.12, duration: 0.8), .scale(to: 0.90, duration: 0.8)])
            ])
        ])))
        run(.repeatForever(.rotate(byAngle: -.pi * 2, duration: 6)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Regular hexagon path centred at origin
    private static func hexagonPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let pt    = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }
}
