//
//  BallNodes.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import SpriteKit

class BallNode: SKNode {
    init(scale: CGFloat) {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// TODO: Other ball variants
class BallShapeNode: SKShapeNode {
    /// Use scale to handle different size of screens
    init(scale: CGFloat) {
        super.init()

        let diameter = kCell * scale / 4
        let rect = CGRect(
            x: -diameter / 2,
            y: -diameter / 2,
            width: diameter,
            height: diameter
        )

        self.path = CGPath(
            ellipseIn: rect,
            transform: nil
        )

        self.fillColor = .red
        self.strokeColor = .white

        self.lineWidth = 2
        self.name = "ball"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BallSpriteNode: SKSpriteNode {
    init(scale: CGFloat) {
        let diameter = kCell * scale / 4

        super.init(
            texture: SKTexture(imageNamed: "ballSprite"),
            color: .clear,
            size: CGSize(width: diameter, height: diameter)
        )

        self.name = "ball"

        self.zPosition = 7
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func makeBallPhysicsBody(scale: CGFloat) -> SKPhysicsBody {
    let radius = kCell * scale / 8
    let body = SKPhysicsBody(circleOfRadius: radius)

    body.isDynamic = true
    body.affectedByGravity = false

    body.friction = 0.0
    body.linearDamping = 0.0
    body.restitution = 1.0

    body.categoryBitMask = PhysicsCategory.ball
    body.contactTestBitMask =
        PhysicsCategory.block | PhysicsCategory.item | PhysicsCategory.ground
    body.collisionBitMask = PhysicsCategory.block | PhysicsCategory.wall

    return body
}
