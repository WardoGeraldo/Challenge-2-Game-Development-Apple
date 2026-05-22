//
//  ProjectileComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 19/05/26.
//

import Foundation
import GameplayKit

class VelocityComponent: GKComponent {
    var velocity: CGVector {
        get {
            physicsBody?.velocity ?? .zero
        }
        set {
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

        super.init()

        // Adding the newly made physics body to the parent's spriteNode
        physicsBody?.isDynamic = true
        self.velocity = velocity
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        // Now 'entity' is not nil, so we can find the sibling sprite component
        if let physicsComponent = entity?.component(
            ofType: PhysicsComponent.self
        ) {
            physicsComponent.physicsBody.isDynamic = true
            physicsComponent.physicsBody.velocity = self.velocity
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
