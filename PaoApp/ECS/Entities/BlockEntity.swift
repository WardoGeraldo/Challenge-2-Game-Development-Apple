//
//  BlockEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

//  BlockEntity.swift
import Foundation
import GameplayKit
import SpriteKit

class BlockEntity: GKEntity {
    init(type: BlockType = .normal, health: Int, ballCount: Int, cell: CGFloat) {
        super.init()

        let node = BlockNode.make(type: type, hp: health, ballCount: ballCount, cell: cell)
        addComponent(RenderComponent(node))
        addComponent(TransformComponent(CGPoint.zero, 0))
        addComponent(HealthComponent(health))
        addComponent(BlockTypeComponent(type))

        let body = SKPhysicsBody(rectangleOf: CGSize(width: cell * 0.9, height: cell * 0.9))
        body.isDynamic = false
        body.friction = 0
        body.restitution = 1
        body.categoryBitMask    = PhysicsCategory.block
        body.collisionBitMask   = PhysicsCategory.ball
        body.contactTestBitMask = PhysicsCategory.ball
        addComponent(PhysicsComponent(body))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
