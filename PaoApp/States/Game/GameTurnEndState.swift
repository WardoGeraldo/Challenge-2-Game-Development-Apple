//
//  GameTurnEndState.swift
//  PaoApp
//
// Types moved to GameIdleState.swift — do not add to Xcode project.
import GameplayKit

// MARK: - GameTurnEndState

// Board is advancing to the next turn — brief transition before aiming resumes
//class GameTurnEndState: GKState {
//    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
//        stateClass == GameAimingState.self
//    }
//}

class GameTurnEndState: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GameAimingState.self
    }
}
