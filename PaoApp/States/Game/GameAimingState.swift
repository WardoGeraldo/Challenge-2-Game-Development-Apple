//
//  GameIdleState.swift
//  PaoApp
//
//  Created by Saujana Shafi on 10/05/26.
//

import GameplayKit

// Player is idle/aiming — pan gesture allowed, balls not yet fired
class GameAimingState: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GameFlyingState.self
    }
}


