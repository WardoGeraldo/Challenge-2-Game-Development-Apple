//
//  GameFlyingState.swift
//  PaoApp
//
//  Created by Axel on 13/05/26.
//

import GameplayKit

// Active while balls are in flight. Fires the volley on entry and polls each
// frame until all balls have landed, then hands off to GameTurnEndState.
class GameFlyingState: GKState {

    weak var context: GameStateContext?

    init(context: GameStateContext) {
        self.context = context
        super.init()
    }

    // MARK: - GKState

    override func didEnter(from previousState: GKState?) {
        context?.fireVolley()
    }

    override func update(deltaTime seconds: TimeInterval) {
        if context?.isVolleyComplete == true {
            stateMachine?.enter(GameTurnEndState.self)
        }
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GameTurnEndState.self
    }
}
