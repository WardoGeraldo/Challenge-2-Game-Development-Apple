//
//  GameTurnEndState.swift
//  PaoApp
//
//  Created by Saujana Shafi on 14/05/26.
//

import Foundation
import GameplayKit

class GameTurnEndState: GameState {
    // MARK: Properties
    var isGameOver: Bool = false

    // MARK: Initialization

    // MARK: GKState overrides

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        // TODO: Do we need to do anything here?
        generateNewRows()

        advanceRows()

        if isGameOver {
            isGameOver = false

            stateMachine?.enter(GameOverState.self)
        } else {
            stateMachine?.enter(GameIdleState.self)
        }
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)

        // TODO: Do we need to do anything here?
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve and refilling states.
        return stateClass is GameOverState.Type
            || stateClass is GameIdleState.Type
    }

    // MARK: Methods
    private func generateNewRows() {
        for _ in 0..<RandomManager.shared.getRandomQuantity() {
            let col = RandomManager.shared.getRandomColumn()

            if RandomManager.shared.getRandomEntity() == .itemBall {
                entityManager.add(
                    ItemBallEntity(
                        row: kRows - 1,
                        col: col + 1,
                    )
                )
            } else {
                entityManager.add(
                    BlockEntity(
                        row: kRows - 1,
                        col: col + 1,
                    )
                )
            }
        }

        RandomManager.shared.resetRandomColumn()
    }

    private func advanceRows() {
        for entity in entityManager.entities(with: GridComponent.self) {
            guard
                let gridComponent = entity.component(
                    ofType: GridComponent.self
                )
            else {
                continue
            }

            gridComponent.row -= 1

            if gridComponent.row <= 0 {
                if entity.component(
                    ofType: ConsumableComponent.self
                ) != nil {
                    entityManager.remove(entity)
                } else if entity.component(ofType: HealthComponent.self) != nil
                {
                    isGameOver = true
                }
            }
        }
    }
}
