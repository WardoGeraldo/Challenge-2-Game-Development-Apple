//
//  BlockEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import SpriteKit

class BlockNode: SKNode {
    init(scale: CGFloat) {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// TODO: Other block variants
class BlockShapeNode: SKShapeNode {
    /// Use scale to handle different size of screens
    init(scale: CGFloat) {
        super.init()

        let size = CGSize(width: kCell * scale, height: kCell * scale)
        let rect = CGRect(
            x: -size.width / 2,
            y: -size.height / 2,
            width: size.width,
            height: size.height
        )

        self.path = CGPath(
            roundedRect: rect,
            cornerWidth: 8 * scale,
            cornerHeight: 8 * scale,
            transform: nil
        )

        self.fillColor = .red
        self.strokeColor = .white

        self.lineWidth = 2
        self.name = "block"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BlockSpriteNode: SKSpriteNode {
    init(scale: CGFloat) {
        let size = CGSize(width: kCell * scale, height: kCell * scale)

        super.init(
            texture: SKTexture(imageNamed: "greenBlockNode"),
            color: .red,
            size: size,
        )

        self.name = "block"

        self.zPosition = 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func makeBlockPhysicsBody(scale: CGFloat) -> SKPhysicsBody {
    let size = CGSize(width: kCell * scale, height: kCell * scale)
    let body = SKPhysicsBody(rectangleOf: size)

    body.isDynamic = false
    body.affectedByGravity = false

    body.friction = 0.0
    body.restitution = 1.0

    body.categoryBitMask = PhysicsCategory.block
    body.collisionBitMask =
        PhysicsCategory.item | PhysicsCategory.wall

    return body
}
