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
        super.didEnter(from: previousState)
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GameAimingState.Type
    }
}
