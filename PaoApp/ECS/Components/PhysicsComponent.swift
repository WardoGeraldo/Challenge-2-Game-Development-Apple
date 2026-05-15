//
//  PhysicsComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit

class PhysicsComponent: GKComponent {
    var physicsBody: SKPhysicsBody

    // Physics Contact
    var contactQueue = [PhysicsContact]()

    //  Accessing the parent's spritenode if any
    var spriteNode: SKNode? {
        return entity?.component(ofType: RenderComponent.self)?.node
            as? SKNode
    }

    init(
        _ body: SKPhysicsBody,
    ) {
        self.physicsBody = body

        super.init()

        // Adding the newly made physics body to the parent's spriteNode
        spriteNode?.physicsBody = physicsBody
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        // Now 'entity' is not nil, so we can find the sibling sprite component
        if let renderComponent = entity?.component(
            ofType: RenderComponent.self
        ) {
            renderComponent.node.physicsBody = self.physicsBody
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
