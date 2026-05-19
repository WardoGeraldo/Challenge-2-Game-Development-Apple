//
//  ControllerSystem.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit
import SpriteKit
import CoreGraphics

// TODO: Change the GKComponent to PositionComponent, ControlComponent
class ControllerSystem: GKComponentSystem<ControlComponent> {
    override init() {
        super.init(componentClass: ControlComponent.self)
    }

    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)

        for controlComponent in components {
            guard
                let renderComponent = controlComponent.entity?.component(
                    ofType: RenderComponent.self
                )
            else { return }

            renderComponent.node.constraints = [
                controlComponent.constraint
            ]
        }
    }
}
