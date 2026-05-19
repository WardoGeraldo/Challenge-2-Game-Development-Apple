//
//  GameOverState.swift
//  PaoApp
//
//  Created by Axel on 13/05/26.
//

import GameplayKit

// Terminal state shown when a block reaches the shooter row.
// GameScene calls restart() (e.g. on tap) to re-enter GameStartState.
class GameOverState: GKState {

    weak var context: GameStateContext?

    init(context: GameStateContext) {
        self.context = context
        super.init()
    }

    // MARK: - GKState

    override func didEnter(from previousState: GKState?) {
        context?.showGameOverScreen()
    }

    // MARK: - Called by GameScene on player restart action

    func restart() {
        context?.resetGame()
        stateMachine?.enter(GameStartState.self)
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GameStartState.self
    }
}
