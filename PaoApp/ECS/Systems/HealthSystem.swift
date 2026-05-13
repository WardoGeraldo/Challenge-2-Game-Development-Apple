//
//  HealthSystem.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit
import SpriteKit
import UIKit

// Applies damage to a block entity, updates its visuals, and reports death.
class HealthSystem {

    // Hits a block entity. Returns true if the block died.
    // `ballCount` is used to colour-code remaining HP relative to ammo.
    @discardableResult
    func hit(entity: GKEntity, ballCount: Int) -> Bool {
        guard let health = entity.component(ofType: HealthComponent.self),
              let render = entity.component(ofType: RenderComponent.self) else { return false }

        let dead = health.hit()
        let node = render.node

        if dead {
            // Disable physics immediately to prevent duplicate contacts
            node.physicsBody = nil
        } else {
            updateColor(in: node, hp: health.health, ballCount: ballCount)
            node.run(.sequence([
                .scale(to: 0.88, duration: 0.04),
                .scale(to: 1.00, duration: 0.08)
            ]))
        }

        return dead
    }

    // Re-colours the block sprite based on remaining HP vs ammo
    private func updateColor(in node: SKNode, hp: Int, ballCount: Int) {
        if let sprite = node.childNode(withName: "blockSprite") as? SKSpriteNode {
            sprite.run(.colorize(with: blockFill(hp: hp, ballCount: ballCount),
                                 colorBlendFactor: 1,
                                 duration: 0.15))
        }
    }

    // Returns the colour matching the remaining HP ratio
    private func blockFill(hp: Int, ballCount: Int) -> UIColor {
        let ratio = CGFloat(hp) / CGFloat(max(ballCount, 1))
        switch ratio {
        case ..<0.6: return UIColor(red: 0.20, green: 0.72, blue: 0.55, alpha: 1) // teal: easy
        case ..<1.0: return UIColor(red: 0.85, green: 0.65, blue: 0.15, alpha: 1) // amber: fair
        default:     return UIColor(red: 0.85, green: 0.28, blue: 0.22, alpha: 1) // red: hard
        }
    }
}
