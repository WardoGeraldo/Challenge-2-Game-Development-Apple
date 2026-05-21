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
    body.contactTestBitMask = PhysicsCategory.block | PhysicsCategory.item
    body.collisionBitMask = PhysicsCategory.block | PhysicsCategory.wall

    return body
}

// TODO: [UI/Node Team] Implement BallNode — the visual for a ball in flight.
//
// BallNode is used by BallEntity's RenderComponent.
//
// Minimum required:
//   - An SKSpriteNode or SKShapeNode circle with radius = GameConstants.ballRadius
//   - Use the "bakpaoAmmo" image asset if available (SKSpriteNode(imageNamed: "bakpaoAmmo"))
//   - Set zPosition = 5
//
// The physics body is added separately by BallEntity (or PhysicsComponent),
// so BallNode itself does NOT need to set physicsBody.
//
// Expected init:
//   init(radius: CGFloat)

// MARK: - AmmoPickupNode

// Bakpao pickup — same asset as the thrown ball, sized to match the grid cell.
class AmmoPickupNode: SKNode {
    init(cell: CGFloat) {
        super.init()
        let size = cell * 0.82

        let sprite = SKSpriteNode(imageNamed: "bakpaoNode")
        sprite.size = CGSize(width: size, height: size)
        addChild(sprite)

        name = "pickup_ammo"
        zPosition = 3

        let body = SKPhysicsBody(circleOfRadius: size * 0.45)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.pickup
        body.collisionBitMask = 0
        body.contactTestBitMask = PhysicsCategory.ball
        physicsBody = body

        run(
            .repeatForever(
                .sequence([
                    .moveBy(x: 0, y: 3, duration: 0.6),
                    .moveBy(x: 0, y: -3, duration: 0.6),
                ])
            )
        )
        run(
            .repeatForever(
                .sequence([
                    .scale(to: 1.08, duration: 0.9),
                    .scale(to: 0.94, duration: 0.9),
                ])
            )
        )
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
