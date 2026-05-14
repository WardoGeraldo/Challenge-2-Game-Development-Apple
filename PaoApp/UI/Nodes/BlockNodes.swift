//
//  BlockNodes.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import SpriteKit

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
    init(scale: CGFloat) {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
