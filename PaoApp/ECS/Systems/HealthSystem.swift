//
//  HealthSystem.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

//import Foundation
//import GameplayKit
//import SpriteKit
//import UIKit
//
//// Applies damage to a block entity, updates its visuals, and reports death.
//class HealthSystem {
//
//    // Hits a block entity. Returns true if the block died.
//    // `ballCount` is used to colour-code remaining HP relative to ammo.
//    @discardableResult
//    func hit(entity: GKEntity, ballCount: Int) -> Bool {
//        guard let health = entity.component(ofType: HealthComponent.self),
//              let render = entity.component(ofType: RenderComponent.self) else { return false }
//
//        let dead = health.hit()
//        let node = render.node
//
//        if dead {
//            // Disable physics immediately to prevent duplicate contacts
//            node.physicsBody = nil
//        } else {
//            updateLabel(in: node, hp: health.health)
//            updateColor(in: node, hp: health.health, ballCount: ballCount)
//            node.run(.sequence([
//                .scale(to: 0.88, duration: 0.04),
//                .scale(to: 1.00, duration: 0.08)
//            ]))
//        }
//
//        return dead
//    }
//
//    // Updates the HP counter label inside a block node
//    private func updateLabel(in node: SKNode, hp: Int) {
//        if let lbl = node.childNode(withName: "hp") as? SKLabelNode {
//            lbl.text = "\(hp)"
//        }
//    }
//
//    // Re-colours the block sprite based on remaining HP vs ammo
//    private func updateColor(in node: SKNode, hp: Int, ballCount: Int) {
//        if let sprite = node.childNode(withName: "blockSprite") as? SKSpriteNode {
//            sprite.run(.colorize(with: blockFill(hp: hp, ballCount: ballCount),
//                                 colorBlendFactor: 1,
//                                 duration: 0.15))
//        }
//    }
//
//    // Returns the colour matching the remaining HP ratio
//    private func blockFill(hp: Int, ballCount: Int) -> UIColor {
//        let ratio = CGFloat(hp) / CGFloat(max(ballCount, 1))
//        switch ratio {
//        case ..<0.6: return UIColor(red: 0.20, green: 0.72, blue: 0.55, alpha: 1) // teal: easy
//        case ..<1.0: return UIColor(red: 0.85, green: 0.65, blue: 0.15, alpha: 1) // amber: fair
//        default:     return UIColor(red: 0.85, green: 0.28, blue: 0.22, alpha: 1) // red: hard
//        }
//    }
//}


//  HealthSystem.swift
import UIKit
import GameplayKit
import SpriteKit

class HealthSystem {

    @discardableResult
    func hit(entity: GKEntity, ballCount: Int) -> Bool {
        guard let health = entity.component(ofType: HealthComponent.self),
              let render = entity.component(ofType: RenderComponent.self)
        else { return false }

        let dead = health.hit()
        let node = render.node

        if dead {
            node.physicsBody = nil
        } else {
            updateLabel(in: node, hp: health.health)
            node.removeAction(forKey: "hitAnim")
            let squash = SKAction.sequence([
                .group([.scaleX(to: 1.08, duration: 0.04), .scaleY(to: 0.92, duration: 0.04)]),
                .group([.scaleX(to: 0.94, duration: 0.05), .scaleY(to: 1.06, duration: 0.05)]),
                .group([.scaleX(to: 1.0,  duration: 0.06), .scaleY(to: 1.0,  duration: 0.06)])
            ])
            let flash = SKAction.sequence([
                .fadeAlpha(to: 0.75, duration: 0.04),
                .fadeAlpha(to: 1.0,  duration: 0.08)
            ])
            node.run(.group([squash, flash]), withKey: "hitAnim")
        }
        return dead
    }

    private func updateLabel(in node: SKNode, hp: Int) {
        guard let lbl = node.childNode(withName: "hp") as? SKLabelNode else { return }
          guard let attrs = lbl.attributedText?.attributes(at: 0, effectiveRange: nil) else { return }
          lbl.attributedText = NSAttributedString(string: "\(hp)", attributes: attrs)
    }
}
