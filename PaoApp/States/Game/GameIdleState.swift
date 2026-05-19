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

// MARK: - GameFlyingState

// Balls are in flight — aiming is disabled, rover movement is active
class GameFlyingState: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GameTurnEndState.self
    }
}

// MARK: - GameTurnEndState

// Board is advancing to the next turn — brief transition before aiming resumes
class GameTurnEndState: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GameAimingState.self
    }
}
