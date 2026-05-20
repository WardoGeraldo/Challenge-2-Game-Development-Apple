//
//  GameTurnEndState.swift
//  PaoApp
//
//  Created by Axel on 13/05/26.
//
import Foundation
import GameplayKit

class GameTurnEndState: GameState {
    // MARK: Properties

    // MARK: Initialization

    // MARK: GKState overrides

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        // TODO: Do we need to do anything here?
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)

        // TODO: Do we need to do anything here?
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GameOverState.Type
            || stateClass is GameIdleState.Type
            || stateClass is GameAimState.Type
    }

    // MARK: Methods
}
