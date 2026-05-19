//
//  GameTurnEndState.swift
//  PaoApp
//
//  Created by Axel on 13/05/26.
//

import GameplayKit

// Brief post-volley state. Advances the board one row on entry, checks for
// game over, then either returns to idle or transitions to game over.
class GameTurnEndState: GKState {

    weak var context: GameStateContext?

    private var isGameOver: Bool = false
    private var elapsed: TimeInterval = 0

    // Seconds to wait before returning to idle (lets the board-advance animation finish).
    private let transitionDelay: TimeInterval = 0.45

    init(context: GameStateContext) {
        self.context = context
        super.init()
    }

    // MARK: - GKState

    override func didEnter(from previousState: GKState?) {
        elapsed = 0
        isGameOver = context?.advanceBoard() ?? false
    }

    override func update(deltaTime seconds: TimeInterval) {
        if isGameOver {
            stateMachine?.enter(GameOverState.self)
            return
        }
        elapsed += seconds
        if elapsed >= transitionDelay {
            stateMachine?.enter(GameIdleState.self)
        }
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GameIdleState.self || stateClass == GameOverState.self
    }
}
