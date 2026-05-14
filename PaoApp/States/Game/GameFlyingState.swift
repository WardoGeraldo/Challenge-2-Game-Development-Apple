//
//  GameFlyingState.swift
//  PaoApp
//
//  Created by Saujana Shafi on 12/05/26.
//

import Foundation
import GameplayKit

class GameFlyingState: GameState {
    // MARK: Properties

    // MARK: Initialization

    // MARK: GKState overrides

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        // TODO:
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)

        // TODO: Implement block step down mechanism

        // TODO: Implement player move to ball touchdown location

        // TODO: Implement trigger block spawn
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve and refilling states.
        return stateClass is GameTurnEndState.Type
    }

    // MARK: Methods
}
