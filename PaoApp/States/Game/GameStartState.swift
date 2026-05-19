//
//  GameStartState.swift
//  PaoApp
//
//  Created by Axel on 13/05/26.
//

import GameplayKit

// Entry point state. Sets up layout, spawns the first rows, then hands off to GameIdleState.
class GameStartState: GKState {

    weak var context: GameStateContext?

    init(context: GameStateContext) {
        self.context = context
        super.init()
    }

    override func didEnter(from previousState: GKState?) {
        context?.setupInitialGame()
        // Move to idle immediately after setup so the player can aim.
        stateMachine?.enter(GameIdleState.self)
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GameIdleState.self
    }
}
