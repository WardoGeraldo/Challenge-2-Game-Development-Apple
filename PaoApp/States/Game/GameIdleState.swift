//
//  GameIdleState.swift
//  PaoApp
//
//  Created by Saujana Shafi on 10/05/26.
//

import GameplayKit

// Resting state between turns. Waits for the player to begin a pan gesture,
// which GameScene intercepts and transitions to GameAimingState.
class GameIdleState: GKState {

    weak var context: GameStateContext?

    init(context: GameStateContext) {
        self.context = context
        super.init()
    }

    override func didEnter(from previousState: GKState?) {
        // Nothing to set up — input is always live; GameScene gates it via currentState check.
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GameAimingState.self
    }
}
