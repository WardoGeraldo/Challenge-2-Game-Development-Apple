//
//  BallNodes.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import SpriteKit

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

class BallNode: SKNode {
    init(scale: CGFloat) {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
