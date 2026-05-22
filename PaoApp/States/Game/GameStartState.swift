//
//  GameStartState.swift
//  PaoApp
//
//  Created by Saujana Shafi on 14/05/26.
//

import Foundation
import GameplayKit

class GameStartState: GameState {
    // MARK: Properties

    // MARK: Initialization

    // MARK: GKState overrides

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        // TODO: Do we need to do anything here?
        startGame()
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)

        // TODO: Do we need to do anything here?
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve and refilling states.
        return stateClass is GameIdleState.Type
    }

    // MARK: Methods
    private func startGame() {
        initPlayer()

        initBall()

        initBlocks()

        stateMachine?.enter(GameIdleState.self)
    }

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
            )
        else {
            return
        }

        let position = CGPoint(
            x: CGFloat(kColumns / 2) * kCell + (kCell / 2),
            y: CGFloat(0) * kCell + (kCell / 2)
        )

        transformComponent.position = position

        controlComponent.pointTo = position

        controlComponent.nextRoundPosition = nil
    }

    private func initBall() {
        guard
            let playerEntity = entityManager.entities(
                with: ControlComponent.self
            )
            .first,
            let transformComponent = playerEntity.component(
                ofType: TransformComponent.self
            )
        else {
            return
        }

        for _ in 0..<kProjectileInitial {
            entityManager.add(
                BallEntity(
                    position: transformComponent.position
                )
            )
        }
    }

    private func initBlocks() {
        for _ in 0..<3 {
            generateNewRows()

            advanceRows()
        }
    }

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
        }
    }

}
