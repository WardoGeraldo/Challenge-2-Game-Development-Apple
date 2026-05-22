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
            x: .zero,
            y: .zero,
            width: size.width,
            height: size.height
        )
        let thickness = kCell * scale / 4
        let groundRect = CGRect(
            x: .zero,
            y: .zero,
            width: rect.width,
            height: thickness
        )

        self.path = CGPath(rect: groundRect, transform: nil)
        self.fillColor = .clear
        self.strokeColor = .red

        //        self.zPosition = 999
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
        x: .zero,
        y: .zero,
        width: size.width,
        height: size.height
    )

    let body = SKPhysicsBody(
        edgeFrom: CGPoint(x: rect.minX, y: rect.minY),
        to: CGPoint(x: rect.maxX, y: rect.minY)
    )

    body.isDynamic = false
    body.affectedByGravity = false

    body.categoryBitMask = PhysicsCategory.ground

    return body
}
