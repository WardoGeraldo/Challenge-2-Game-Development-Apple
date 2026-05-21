//
//  ItemBallNodes.swift
//  PaoApp
//
//  Created by Saujana Shafi on 20/05/26.
//

import Foundation
import SpriteKit

class ItemBallShapeNode: SKShapeNode {
    /// Use scale to handle different size of screens
    init(scale: CGFloat) {
        super.init()

        let diameter = kCell * scale / 2
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
        self.name = "item-ball"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ItemBallSpriteNode: SKSpriteNode {
    init(scale: CGFloat) {
        let size = CGSize(width: kCell * scale, height: kCell * scale)

        super.init(
            texture: SKTexture(imageNamed: "ballSprite"),
            color: .red,
            size: size,
        )

        self.name = "itemBall"

        self.zPosition = 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func makeItemBallPhysicsBody(scale: CGFloat) -> SKPhysicsBody {
    let radius = kCell * scale / 4
    let body = SKPhysicsBody(circleOfRadius: radius)

    body.isDynamic = true
    body.affectedByGravity = false

    body.friction = 0.0
    body.linearDamping = 0.0
    body.restitution = 1.0

    body.categoryBitMask = PhysicsCategory.item
    body.collisionBitMask = PhysicsCategory.block | PhysicsCategory.wall

    return body
}
