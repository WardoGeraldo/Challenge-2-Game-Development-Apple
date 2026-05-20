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
        
        addChild(sprite)
        addChild(border)
        addChild(arrow)
        addChild(hpLabel(hp: hp, fontSize: cell * 0.30, offsetY: -cell * 0.20))
    }
    
    // MARK: - Helpers

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
        lbl.attributedText = NSAttributedString(string: "\(hp)", attributes: [
              .font:            UIFont(name: "Melon-pop", size: fontSize) ?? UIFont.systemFont(ofSize:
          fontSize),
//              .foregroundColor: UIColor(red: 242/255, green: 211/255, blue: 141/255, alpha: 1),
              .foregroundColor: UIColor(red: 255/255, green: 231/255, blue: 179/255, alpha: 1),
              .strokeColor:     UIColor(red:92/255, green:53/255, blue:22/255,  alpha: 1),
              .strokeWidth:     -5
          ])  
        
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
}

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
