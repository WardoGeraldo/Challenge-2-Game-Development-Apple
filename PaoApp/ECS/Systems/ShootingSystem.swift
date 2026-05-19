//
//  ShootingSystem.swift
//  PaoApp
//
//  Created by Saujana Shafi on 19/05/26.
//

import Foundation
import GameplayKit
import SpriteKit

class ShootingSystem: GKComponentSystem<ControlComponent> {
    var lastUpdateInterval = TimeInterval(0)

    override init() {
        super.init(componentClass: ControlComponent.self)
    }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        for controlComponent in components {
            if controlComponent.projectiles.count > .zero {
                if CACurrentMediaTime() - lastUpdateInterval
                    > kProjectileShotInterval
                {
                    lastUpdateInterval = CACurrentMediaTime()

                    guard
                        let projectile = controlComponent.projectiles.popLast(),
                        let velocityComponent = projectile.component(
                            ofType: VelocityComponent.self
                        ),
                        let transformComponent = projectile.component(
                            ofType: TransformComponent.self
                        ),
                        let playerTransformComponent = controlComponent.entity?
                            .component(ofType: TransformComponent.self)
                    else {
                        continue
                    }

                    transformComponent.position =
                        playerTransformComponent.position

                    let direction =
                        (controlComponent.pointTo - transformComponent.position)
                        .normalized()
                    let velocity = CGVector(
                        dx: direction.x * kProjectileSpeed,
                        dy: direction.y * kProjectileSpeed,
                    )

                    velocityComponent.velocity = velocity
                }
            }
        }
    }
}
