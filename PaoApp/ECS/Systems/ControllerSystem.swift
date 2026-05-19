//
//  ControllerSystem.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit
import SpriteKit
import CoreGraphics

class ControllerSystem: GKComponentSystem<GKComponent> {

    init(scene: SKScene) {
        self.scene = scene
    }

    // Adds or updates the dashed aim-line from origin in the given direction
    func updateAimLine(from origin: CGPoint, angle: CGFloat, topY: CGFloat) {
        if aimLine == nil {
            let ln = SKShapeNode()
            ln.strokeColor = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.5)
            ln.lineWidth   = 2
            ln.zPosition   = 9
            ln.name        = "ui"
            scene?.addChild(ln)
            aimLine = ln
        }

        guard let ln = aimLine else { return }
        let len = topY - origin.y + 10
        let p   = CGMutablePath()
        p.move(to: origin)
        p.addLine(to: CGPoint(x: origin.x + cos(angle) * len,
                              y: origin.y + sin(angle) * len))
        ln.path = p.copy(dashingWithPhase: 0, lengths: [10, 8])
    }

    // Removes the aim-line from the scene
    func removeAimLine() {
        aimLine?.removeFromParent()
        aimLine = nil
    }
}
