//
//  PlayerNodes.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import SpriteKit

// TODO: [UI/Node Team] Implement PlayerNode — the shooter marker at the bottom of the board.
//
// PlayerNode visually marks where balls will be fired from.
//
// Minimum required:
//   - A small filled circle (radius = GameConstants.ballRadius) or an arrow sprite
//   - Use the "bakpaoAmmo" image asset if available
//   - zPosition = 3
//   - No physics body needed — it is a static visual only
//
// Expected init:
//   init(radius: CGFloat)
//
// GameScene places it at (shootX, shootY) and repositions it after each volley
// to wherever the first ball landed (the new shoot position for the next turn).

class PlayerNode: SKNode {
    init(scale: CGFloat) {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
