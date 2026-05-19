//
//  GameAimingState.swift
//  PaoApp
//
//  Created by Axel on 13/05/26.
//

import Foundation
import GameplayKit

class GameAimState: GameState {
    // MARK: Properties

    // MARK: Initialization

    // MARK: GKState overrides

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        // TODO: Implement draw aiming line
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)

        // TODO: Implement remove aiming line
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve and refilling states.
        return stateClass is GameFlyingState.Type
            || stateClass is GameIdleState.Type
    }

    // MARK: Methods
}
