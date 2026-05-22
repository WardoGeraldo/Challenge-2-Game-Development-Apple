//
//  PhysicsComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit

class PhysicsComponent: GKComponent {
    private var _physicsBody: SKPhysicsBody

    var physicsBody: SKPhysicsBody {
        get {
            _physicsBody
        }
        set {
            _physicsBody = newValue
            spriteNode?.physicsBody = _physicsBody
        }
    }

    // Physics Contact
    var contactQueue = [SKPhysicsContact]()

    //  Accessing the parent's spritenode if any
    var spriteNode: SKNode? {
        return entity?.component(ofType: RenderComponent.self)?.node
            as? SKNode
    }

    init(
        _ body: SKPhysicsBody,
    ) {
        self._physicsBody = body

        super.init()

        self.physicsBody = body
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
