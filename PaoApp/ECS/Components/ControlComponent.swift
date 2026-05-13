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


