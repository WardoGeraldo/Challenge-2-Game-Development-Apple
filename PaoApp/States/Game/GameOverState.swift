//
//  GameOverState.swift
//  PaoApp
//
//  Created by Saujana Shafi on 14/05/26.
//

import Foundation
import GameplayKit

class GameOverState: GameState {
    // MARK: Properties

    // MARK: Initialization

    // MARK: GKState overrides

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        // TODO: Do we need to do anything here?
        stateMachine?.enter(GameStartState.self)
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)

        // TODO: Do we need to do anything here?
        resetGame()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve and refilling states.
        return stateClass is GameStartState.Type
    }

    // MARK: Methods
    private func resetGame() {
        print("Resetting game...")
        print("Clearing entities...")

        //        print("Score: \(ScoreManager.shared.score)")
        //        print("Highscore: \(ScoreManager.shared.highScore)")

        let projectiles = entityManager.entities(with: ProjectileComponent.self)

        for projectile in projectiles {
            entityManager.remove(projectile)
        }

        let blocks = entityManager.entities(with: HealthComponent.self)

        for block in blocks {
            entityManager.remove(block)
        }

        let items = entityManager.entities(with: ConsumableComponent.self)

        for item in items {
            entityManager.remove(item)
        }
    }
}
