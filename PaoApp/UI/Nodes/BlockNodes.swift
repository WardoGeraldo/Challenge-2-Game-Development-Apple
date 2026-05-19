//
//  BlockNodes.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import SpriteKit
import UIKit

// TODO: [UI/Node Team] Implement BlockNode — the visual for a block on the board.
//
// BlockNode is used by BlockEntity's RenderComponent.
//
// Minimum required:
//   - An SKShapeNode rectangle sized to `cell × cell` with cornerRadius
//   - Fill color based on block type (normal / bomb / rover) and HP ratio
//   - A child SKLabelNode named "hpLabel" showing the current HP number
//   - Set zPosition = 2
//
// Expected init:
//   init(cell: CGFloat, hp: Int, ballCount: Int)
//   or a static factory: static func make(type: BlockType, hp: Int, ballCount: Int, cell: CGFloat) -> BlockNode
//
// HealthSystem will find the "hpLabel" child by name and update its text after each hit.
// The physics body is NOT set here — BlockEntity (via PhysicsComponent) handles that.
//
// Reference: ECS_Prototype → BlockNodes.swift (full implementation with color gradients and spawn animation)

class BlockNode: SKNode {

    // MARK: - Factory

    static func make(type: BlockType, hp: Int, ballCount: Int, cell: CGFloat) -> BlockNode {
        let node = BlockNode()
        node.name      = "block"
        node.zPosition = 3
        node.alpha     = 0
        node.setScale(0.2)

        switch type {
        case .normal:
            node.buildNormal(hp: hp, ballCount: ballCount, cell: cell)
        case .triangle(let flipped):
            node.buildTriangle(hp: hp, ballCount: ballCount, cell: cell, flipped: flipped)
        case .bomb:
            node.buildBomb(hp: hp, ballCount: ballCount, cell: cell)
        case .rover:
            node.buildRover(hp: hp, ballCount: ballCount, cell: cell)
        }

        // Spawn-in animation
        node.run(.group([
            .fadeIn(withDuration: 0.35),
            .scale(to: 1.0, duration: 0.35)
        ]))
        return node
    }

    // MARK: - Block Builders

//    private func buildNormal(hp: Int, ballCount: Int, cell: CGFloat) {
//        let sprite = SKSpriteNode(
//            color: BlockNode.blockFill(hp: hp, ballCount: ballCount),
//            size: CGSize(width: cell, height: cell)
//        )
//        sprite.name = "blockSprite"
//
//        let border = SKShapeNode(
//            rect: CGRect(x: -cell/2, y: -cell/2, width: cell, height: cell),
//            cornerRadius: 7
//        )
//        border.fillColor   = .clear
//        border.strokeColor = UIColor(white: 1, alpha: 0.12)
//        border.lineWidth   = 1
//        border.zPosition   = 1
//
//        physicsBody = blockBody(size: CGSize(width: cell, height: cell))
//        addChild(sprite)
//        addChild(border)
//        addChild(hpLabel(hp: hp, fontSize: cell * 0.38))
//    }
    
    private func buildNormal(
        hp: Int,
        ballCount: Int,
        cell: CGFloat
    ) {

        let visualSize = cell

        //
        // BLOCK SPRITE
        //
        let sprite = SKSpriteNode(imageNamed: "greenBlockNode")

        sprite.size = CGSize(
            width: visualSize,
            height: visualSize
        )

        sprite.name = "blockSprite"

        sprite.zPosition = 1

        sprite.texture?.filteringMode = .nearest

        addChild(sprite)

        //
        // PHYSICS
        //
        physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(
                width: visualSize,
                height: visualSize
            )
        )

        physicsBody?.isDynamic = false
        physicsBody?.friction = 0
        physicsBody?.restitution = 1

        physicsBody?.categoryBitMask = PhysicsCategory.block

        physicsBody?.collisionBitMask =
            PhysicsCategory.ball

        physicsBody?.contactTestBitMask =
            PhysicsCategory.ball

        //
        // HP LABEL
        //
        let hpNode = hpLabel(
            hp: hp,
            fontSize: visualSize * 0.34
        )

        hpNode.zPosition = 5

        addChild(hpNode)

        //
        // FLOAT ANIMATION
        //
        let float = SKAction.sequence([

            .moveBy(
                x: 0,
                y: 2,
                duration: 1.0
            ),

            .moveBy(
                x: 0,
                y: -2,
                duration: 1.0
            )
        ])

        float.timingMode = .easeInEaseOut

        sprite.run(
            .repeatForever(float),
            withKey: "idleFloat"
        )
    }

    private func buildTriangle(hp: Int, ballCount: Int, cell: CGFloat, flipped: Bool) {
        let h    = cell
        let path = CGMutablePath()
        if flipped {
            path.move(to: CGPoint(x: -h/2, y: -h/2))
            path.addLine(to: CGPoint(x:  h/2, y: -h/2))
            path.addLine(to: CGPoint(x:  h/2, y:  h/2))
        } else {
            path.move(to: CGPoint(x: -h/2, y: -h/2))
            path.addLine(to: CGPoint(x:  h/2, y: -h/2))
            path.addLine(to: CGPoint(x: -h/2, y:  h/2))
        }
        path.closeSubpath()

        let shape = SKShapeNode(path: path)
        shape.fillColor   = UIColor(red: 0.85, green: 0.62, blue: 0.20, alpha: 1)
        shape.strokeColor = UIColor(white: 1, alpha: 0.18)
        shape.lineWidth   = 1
        shape.name        = "blockSprite"

        let pts: [CGPoint] = flipped
            ? [CGPoint(x: -h/2, y: -h/2), CGPoint(x:  h/2, y: -h/2), CGPoint(x:  h/2, y:  h/2)]
            : [CGPoint(x: -h/2, y: -h/2), CGPoint(x:  h/2, y: -h/2), CGPoint(x: -h/2, y:  h/2)]
        let triBody = SKPhysicsBody(polygonFrom: CGPath.polygon(points: pts))
        setupBlockBodyProperties(triBody)
        physicsBody = triBody

        addChild(shape)
        addChild(hpLabel(hp: hp, fontSize: cell * 0.30))
    }

// TODO: Other block variants
class BlockShapeNode: SKShapeNode {
    /// Use scale to handle different size of screens
    init(scale: CGFloat) {
        super.init()

        // TODO: Implement Block Shape Node attributes here
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class BlockPhysicsBody: SKPhysicsBody {
    override init() {
        super.init()

        // TODO: Implement Block Physics Body attributes here
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
