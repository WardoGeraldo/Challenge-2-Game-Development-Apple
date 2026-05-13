//
//  GameFlyingState.swift
//  PaoApp
//
// Types moved to GameIdleState.swift — do not add to Xcode project.

import GameplayKit

// MARK: - GameFlyingState

// Balls are in flight — aiming is disabled, rover movement is active
class GameFlyingState: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GameTurnEndState.self
    }
}
