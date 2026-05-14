//
//  ControlComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

// TODO: [ECS Team] Add properties to ControlComponent for player-controlled values.
//
// Suggested properties:
//   var shotAngle: CGFloat = .pi / 2   → current aim angle (updated by GameAimingState)
//   var ballCount: Int = 1             → number of balls fired per turn (grows with ammo pickups)
//
// GameScene.fireVolley() will read ballCount from this component instead of the current hardcoded value.
// GameAimingState.updateAim(angle:) will write to shotAngle via the context's pendingShotAngle.

class ControlComponent: GKComponent {

}
