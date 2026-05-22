//
//  ProjectileComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 19/05/26.
//

import Foundation
import GameplayKit

class VelocityComponent: GKComponent {
    private var _velocity: CGVector = .zero

    var velocity: CGVector {
        get {
            _velocity
        }
        set {
            _velocity = newValue
            physicsBody?.velocity = newValue
        }
    }

    //  Accessing the parent's spritenode if any
    var physicsBody: SKPhysicsBody? {
        return entity?.component(ofType: PhysicsComponent.self)?.physicsBody
            as? SKPhysicsBody
    }

    init(
        _ velocity: CGVector = CGVector(dx: 0, dy: 0),
    ) {
        self._velocity = velocity

        super.init()

        self.velocity = velocity
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        // Now 'entity' is not nil, so we can find the sibling sprite component
        if let physicsComponent = entity?.component(
            ofType: PhysicsComponent.self
        ) {
            physicsComponent.physicsBody.velocity = self.velocity
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
