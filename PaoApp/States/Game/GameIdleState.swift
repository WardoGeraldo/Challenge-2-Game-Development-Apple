//
//  GameIdleState.swift
//  PaoApp
//
//  Created by Saujana Shafi on 10/05/26.
//

import Foundation
import GameplayKit

class GameIdleState: GameState {
    // MARK: Properties

    // MARK: Initialization

    // MARK: GKState overrides

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        // TODO: Do we need to do anything here?
        initPlayer()
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)

        // TODO: Do we need to do anything here?
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve and refilling states.
        return stateClass is GameAimState.Type
    }

    // MARK: Methods
    private func initPlayer() {
        guard
            let playerEntity = entityManager.entities(
                with: ControlComponent.self
            )
            .first,
            let transformComponent = playerEntity.component(
                ofType: TransformComponent.self
            ),
            let controlComponent = playerEntity.component(
                ofType: ControlComponent.self
            ),
            let renderComponent = playerEntity.component(
                ofType: RenderComponent.self
            )
        else {
            return
        }

        let position = transformComponent.position

        controlComponent.pointTo = position

        renderComponent.node.constraints = [
            controlComponent.constraint
        ]
    }

}
