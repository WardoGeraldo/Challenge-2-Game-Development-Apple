//
//  ControlComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit
import CoreGraphics

// Holds the player's current aiming state
class ControlComponent: GKComponent {
    var isAiming: Bool   = false
    var shotAngle: CGFloat = .pi / 2   // default: straight up

    override init() { super.init() }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - VelocityComponent

// Tracks per-ball flight state needed for landing detection.
// Actual velocity lives in SKPhysicsBody; this holds ECS-side metadata.
class VelocityComponent: GKComponent {
    // True once the ball has risen above the shooter row at least once.
    // Landing is only triggered AFTER the ball has risen — prevents false early landing.
    var hasRisen: Bool = false
    // Accumulated flight time (seconds). Used to force-land balls that get stuck.
    var flightTime: CGFloat = 0

    override init() { super.init() }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
