//
//  ArenaNode.swift
//  PaoApp
//
//  Created by Saujana Shafi on 15/05/26.
//

import Foundation
import SpriteKit

class ArenaShapeNode: SKShapeNode {
    init(scale: CGFloat) {
        super.init()

        let size = CGSize(
            width: kCell * scale * CGFloat(kColumns),
            height: kCell * scale * CGFloat(kRows),
        )
        let rect = CGRect(
            x: -size.width / 2,
            y: -size.height / 2,
            width: size.width,
            height: size.height,
        )
        let cellSize = kCell * scale

        self.path = CGPath(
            rect: rect,
            transform: nil,
        )

        self.fillColor = .black
        self.strokeColor = .white

        self.lineWidth = 2
        self.name = "arena"

        let lightColor = SKColor(white: 0.18, alpha: 1)
        let darkColor = SKColor(white: 0.08, alpha: 1)

        for row in 0..<kRows {
            for column in 0..<kColumns {
                let cellNode = SKShapeNode(
                    rectOf: CGSize(width: cellSize, height: cellSize)
                )
                cellNode.position = CGPoint(
                    x: rect.minX + CGFloat(column) * cellSize + (cellSize / 2),
                    y: rect.minY + CGFloat(row) * cellSize + (cellSize / 2)
                )
                let isLight = (row + column) % 2 == 0
                cellNode.fillColor = isLight ? lightColor : darkColor
                cellNode.strokeColor = SKColor.clear
                cellNode.lineWidth = 0
                cellNode.name = "arena-cell"
                addChild(cellNode)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func makeArenaPhysicsBody(scale: CGFloat) -> SKPhysicsBody {
    let size = CGSize(
        width: kCell * scale * CGFloat(kColumns),
        height: kCell * scale * CGFloat(kRows),
    )
    let rect = CGRect(
        x: -size.width / 2,
        y: -size.height / 2,
        width: size.width,
        height: size.height,
    )
    let body = SKPhysicsBody(edgeLoopFrom: rect)

    body.isDynamic = false
    body.affectedByGravity = false

    body.friction = 0.0
    body.restitution = 1.0

    body.categoryBitMask = PhysicsCategory.wall
    body.collisionBitMask =
        PhysicsCategory.ball | PhysicsCategory.item | PhysicsCategory.block

    return body
}
