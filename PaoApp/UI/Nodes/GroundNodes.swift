//
//  GroundNodes.swift
//  PaoApp
//
//  Created by Saujana Shafi on 20/05/26.
//

import Foundation
import SpriteKit

class GroundShapeNode: SKShapeNode {
    init(scale: CGFloat) {
        super.init()

        let size = CGSize(
            width: kCell * scale * CGFloat(kColumns),
            height: kCell * scale * CGFloat(kRows)
        )
        let rect = CGRect(
            x: -size.width / 2,
            y: -size.height / 2,
            width: size.width,
            height: size.height
        )
        let thickness = kCell * scale / 4
        let groundRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: thickness
        )

        self.path = CGPath(rect: groundRect, transform: nil)
        self.fillColor = .clear
        self.strokeColor = .red
        self.zPosition = 999
        self.lineWidth = 2
        self.name = "ground"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func makeGroundPhysicsBody(scale: CGFloat) -> SKPhysicsBody {
    let size = CGSize(
        width: kCell * scale * CGFloat(kColumns),
        height: kCell * scale * CGFloat(kRows)
    )
    let rect = CGRect(
        x: -size.width / 2,
        y: -size.height / 2,
        width: size.width,
        height: size.height
    )

    let body = SKPhysicsBody(
        edgeFrom: CGPoint(x: rect.minX, y: rect.minY),
        to: CGPoint(x: rect.maxX, y: rect.minY)
    )

    body.isDynamic = true
    body.affectedByGravity = false
    body.pinned = true
    body.friction = 0.0
    body.restitution = 1.0

    body.categoryBitMask = PhysicsCategory.ground
    body.contactTestBitMask =
        PhysicsCategory.ball | PhysicsCategory.item | PhysicsCategory.block

    return body
}
