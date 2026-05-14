//
//  BallEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

// TODO: [ECS Team] Implement BallEntity.
// BallEntity represents a single ball in flight during a volley.
//
// Required components:
//   - RenderComponent(BallNode(...))   → the visual circle node
//   - PhysicsComponent(body)           → SKPhysicsBody(circleOfRadius:)
//     Physics settings: friction=0, restitution=1, linearDamping=0
//     categoryBitMask  = PhysicsCategory.ball
//     collisionBitMask = PhysicsCategory.wall | PhysicsCategory.block
//     contactTestBitMask = PhysicsCategory.block
//     usesPreciseCollisionDetection = true
//
// Expected init signature:
//   init(node: BallNode, radius: CGFloat)
//
// After entityManager.add(entity) is called, GameScene.fireVolley() will set
// the physicsBody velocity to launch the ball at the shot angle.
//
// Reference: ECS_Prototype → GameScene.fireOneBall()

class BallEntity: GKEntity {

}
