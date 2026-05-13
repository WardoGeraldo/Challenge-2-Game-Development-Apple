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

