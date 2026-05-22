//
//  GameAimState.swift
//  PaoApp
//
//  Created by Saujana Shafi on 12/05/26.
//

import Foundation
import GameplayKit

class GameAimState: GameState {
    // MARK: Properties

    // MARK: Initialization

    // MARK: GKState overrides

    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)

        guard entityManager.entities(with: AimLineEntity.self).isEmpty else {
            return
        }

        let aimEntity = AimLineEntity()
        entityManager.add(aimEntity)
    }

    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)

        guard
            let aimEntity = entityManager.entities(with: AimLineEntity.self)
                .first
        else {
            return
        }

        entityManager.remove(aimEntity)
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve and refilling states.
        return stateClass is GameFlyingState.Type
            || stateClass is GameIdleState.Type
    }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        guard
            let playerEntity = entityManager.entities(
                with: ControlComponent.self
            ).first,
            let controlComponent = playerEntity.component(
                ofType: ControlComponent.self
            ),
            let playerRenderComponent = playerEntity.component(
                ofType: RenderComponent.self
            ),
            let aimEntity = entityManager.entities(with: AimLineEntity.self)
                .first,
            let aimRenderComponent = aimEntity.component(
                ofType: RenderComponent.self
            ),
            let scene = playerRenderComponent.node.scene
        else {
            return
        }

        playerRenderComponent.node.constraints = [
            controlComponent.constraint
        ]

        let start = playerRenderComponent.node.position
        let direction = (controlComponent.pointTo - start).normalized()
        let maxDistance = max(scene.size.width, scene.size.height)
        let end = CGPoint(
            x: start.x + direction.x * maxDistance,
            y: start.y + direction.y * maxDistance
        )

        var hitPoint = end
        scene.physicsWorld.enumerateBodies(
            alongRayStart: start,
            end: end
        ) { body, point, _, stop in
            let categories =
                PhysicsCategory.block
                | PhysicsCategory.wall
                | PhysicsCategory.item
            if body.categoryBitMask & categories != 0 {
                hitPoint = point
                stop.pointee = true
            }
        }

        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: hitPoint)
        (aimRenderComponent.node as? SKShapeNode)?.path = path
    }

    // MARK: Methods
}
