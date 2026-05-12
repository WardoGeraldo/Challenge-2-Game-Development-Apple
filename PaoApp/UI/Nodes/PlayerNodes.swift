//
//  PlayerNodes.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import SpriteKit
import UIKit

// Static visual marker for the shooter origin position.
// Pulses gently to indicate where the next volley will launch from.
class PlayerNode: SKNode {
    init(radius: CGFloat) {
        super.init()
        name      = "player"
        zPosition = 4

        // Outer glow ring
        let outer = SKShapeNode(circleOfRadius: radius * 1.1)
        outer.fillColor   = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.08)
        outer.strokeColor = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.35)
        outer.lineWidth   = 1.2
        addChild(outer)

        // Inner solid dot
        let inner = SKShapeNode(circleOfRadius: radius * 0.55)
        inner.fillColor   = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.55)
        inner.strokeColor = .clear
        addChild(inner)

        // Idle pulse animation
        outer.run(.repeatForever(.sequence([
            .scale(to: 1.25, duration: 0.9),
            .scale(to: 1.00, duration: 0.9)
        ])))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
