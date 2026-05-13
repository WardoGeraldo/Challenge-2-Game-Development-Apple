//
//  VelocityComponent.swift
//  PaoApp
//
// Types moved to ControlComponent.swift — do not add to Xcode project.

import GameplayKit
import SpriteKit

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
