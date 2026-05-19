//
//  BlockNodes.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import SpriteKit
import UIKit

// MARK: - BlockType

// All available block types in the game
enum BlockType {
    case normal
    case triangle(flipped: Bool)   // unlocks turn 5 — diagonal bounces
    case bomb                      // unlocks turn 10 — explodes adjacent blocks on death
    case rover                     // unlocks turn 3 — slides left/right each turn

    var isBomb: Bool {
        if case .bomb = self { return true }
        return false
    }

    var isRover: Bool {
        if case .rover = self { return true }
        return false
    }
}

// MARK: - BlockNode

// Factory for all block visual types.
// Each block carries named child nodes ("blockSprite", "hp") used by HealthSystem.
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

    private func buildBomb(hp: Int, ballCount: Int, cell: CGFloat) {
        let sprite = SKSpriteNode(
            color: UIColor(red: 0.85, green: 0.22, blue: 0.22, alpha: 1),
            size: CGSize(width: cell, height: cell)
        )
        sprite.name = "blockSprite"

        // Pulsing glow to signal danger
        let glow = SKShapeNode(
            rect: CGRect(x: -cell/2, y: -cell/2, width: cell, height: cell),
            cornerRadius: 7
        )
        glow.fillColor   = .clear
        glow.strokeColor = UIColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 0.5)
        glow.lineWidth   = 2
        glow.zPosition   = 1
        glow.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.15, duration: 0.7),
            .fadeAlpha(to: 0.80, duration: 0.7)
        ])))

        let icon = SKLabelNode(text: "💣")
        icon.fontSize              = cell * 0.38
        icon.verticalAlignmentMode = .center
        icon.position              = CGPoint(x: 0, y: cell * 0.08)

        physicsBody = blockBody(size: CGSize(width: cell, height: cell))
        addChild(sprite)
        addChild(glow)
        addChild(icon)
        addChild(hpLabel(hp: hp, fontSize: cell * 0.28, offsetY: -cell * 0.24))
    }

    private func buildRover(hp: Int, ballCount: Int, cell: CGFloat) {
        let sprite = SKSpriteNode(
            color: UIColor(red: 0.15, green: 0.58, blue: 0.52, alpha: 1),
            size: CGSize(width: cell, height: cell)
        )
        sprite.name = "blockSprite"

        let border = SKShapeNode(
            rect: CGRect(x: -cell/2, y: -cell/2, width: cell, height: cell),
            cornerRadius: 7
        )
        border.fillColor   = .clear
        border.strokeColor = UIColor(white: 1, alpha: 0.14)
        border.lineWidth   = 1
        border.zPosition   = 1

        let arrow = SKLabelNode(text: "⟷")
        arrow.fontSize              = cell * 0.30
        arrow.fontColor             = UIColor(white: 1, alpha: 0.65)
        arrow.verticalAlignmentMode = .center
        arrow.position              = CGPoint(x: 0, y: cell * 0.08)

        physicsBody = blockBody(size: CGSize(width: cell, height: cell))
        addChild(sprite)
        addChild(border)
        addChild(arrow)
        addChild(hpLabel(hp: hp, fontSize: cell * 0.30, offsetY: -cell * 0.20))
    }

    // MARK: - Helpers

    private func blockBody(size: CGSize) -> SKPhysicsBody {
        let body = SKPhysicsBody(rectangleOf: size)
        setupBlockBodyProperties(body)
        return body
    }

    private func setupBlockBodyProperties(_ body: SKPhysicsBody) {
        body.isDynamic          = false
        body.friction           = 0
        body.restitution        = 1
        body.categoryBitMask    = PhysicsCategory.block
        body.collisionBitMask   = PhysicsCategory.ball
        body.contactTestBitMask = PhysicsCategory.ball
    }

//    private func hpLabel(hp: Int, fontSize: CGFloat, offsetY: CGFloat = 0) -> SKLabelNode {
//        let lbl = SKLabelNode(fontNamed: GameConstants.fontName)
//        lbl.name                    = "hp"
//        lbl.text                    = "\(hp)"
//        lbl.fontSize                = fontSize
//        lbl.fontColor               = .white
//        lbl.verticalAlignmentMode   = .center
//        lbl.horizontalAlignmentMode = .center
//        lbl.position                = CGPoint(x: 0, y: offsetY)
//        return lbl
//    }
    
    
    private func cellTopOffset(fontSize: CGFloat) -> CGFloat {
        return fontSize * 0.9
    }
    
    private func hpLabel(hp: Int, fontSize: CGFloat, offsetY: CGFloat = 0) -> SKLabelNode {

        let lbl = SKLabelNode(fontNamed: "MelonPop-Regular")

        lbl.name                    = "hp"
        lbl.text                    = "\(hp)"
        lbl.fontSize                = fontSize
        lbl.fontColor               = .white

        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center

        // posisi angka di atas block
        lbl.position = CGPoint(x: 0, y: fontSize * 0.9 + offsetY)

        return lbl
    }

    // Colour shows HP relative to current ball count
    static func blockFill(hp: Int, ballCount: Int) -> UIColor {
        let ratio = CGFloat(hp) / CGFloat(max(ballCount, 1))
        switch ratio {
        case ..<0.6: return UIColor(red: 0.20, green: 0.72, blue: 0.55, alpha: 1)
        case ..<1.0: return UIColor(red: 0.85, green: 0.65, blue: 0.15, alpha: 1)
        default:     return UIColor(red: 0.85, green: 0.28, blue: 0.22, alpha: 1)
        }
    }
}

// MARK: - CGPath polygon helper

extension CGPath {
    static func polygon(points: [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        guard let first = points.first else { return path }
        path.move(to: first)
        points.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
}
