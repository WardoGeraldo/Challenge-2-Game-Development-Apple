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
    var projectiles = [GKEntity]()
    var flyingProjectiles = [GKEntity]()

    var lastUpdateInterval = TimeInterval(0)

    // MARK: Initialization

    // MARK: GKState overrides

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        // TODO: Trigger shooting
        projectiles = entityManager.entities(with: ProjectileComponent.self)
        flyingProjectiles = []
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)

        // TODO: Implement block step down mechanism

        // TODO: Implement player move to ball touchdown location
        guard
            let playerEntity = entityManager.entities(
                with: ControlComponent.self
            ).first,
            let playerTransformComponent = playerEntity.component(
                ofType: TransformComponent.self
            ),
            let playerControlComponent = playerEntity.component(
                ofType: ControlComponent.self
            ), let toPosition = playerControlComponent.nextRoundPosition
        else {
            return
        }

        playerTransformComponent.position = toPosition
        playerControlComponent.nextRoundPosition = nil

        // TODO: Implement trigger block spawn
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve and refilling states.
        return stateClass is GameTurnEndState.Type
    }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        if projectiles.count > .zero {
            if CACurrentMediaTime() - lastUpdateInterval
                > kProjectileShotInterval
            {
                lastUpdateInterval = CACurrentMediaTime()

                guard
                    let projectile = projectiles.popLast(),
                    let velocityComponent = projectile.component(
                        ofType: VelocityComponent.self
                    ),
                    let transformComponent = projectile.component(
                        ofType: TransformComponent.self
                    ),
                    let playerEntity = entityManager.entities(
                        with: ControlComponent.self
                    ).first,
                    let playerTransformComponent = playerEntity.component(
                        ofType: TransformComponent.self
                    ),
                    let playerControlComponent = playerEntity.component(
                        ofType: ControlComponent.self
                    )
                else {
                    return
                }

                transformComponent.position =
                    playerTransformComponent.position

                let direction =
                    (playerControlComponent.pointTo
                    - transformComponent.position)
                    .normalized()
                let velocity = CGVector(
                    dx: direction.x * kProjectileSpeed,
                    dy: direction.y * kProjectileSpeed,
                )

                velocityComponent.velocity = velocity
                flyingProjectiles.append(projectile)
            }
        } else if flyingProjectiles.count > .zero {
            if flyingProjectiles.allSatisfy({ entity in
                guard
                    let velocityComponent = entity.component(
                        ofType: VelocityComponent.self
                    )
                else {
                    return false
                }
                return velocityComponent.velocity == .zero
            }) {
                stateMachine?.enter(GameTurnEndState.self)
            }
        }

    }

    // MARK: Methods
}
