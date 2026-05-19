//
//  TransformComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit

class TransformComponent: GKComponent {
    private var _position: CGPoint

    var position: CGPoint {
        get {
            spriteNode?.position ?? _position
        }
        set {
            _position = newValue
            spriteNode?.position = newValue
        }
    }

    //  Accessing the parent's spritenode if any
    var spriteNode: SKNode? {
        return entity?.component(ofType: RenderComponent.self)?.node
            as? SKNode
    }

    init(_ position: CGPoint) {
        self._position = position

        super.init()

        self.position = position
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        // Now 'entity' is not nil, so we can find the sibling sprite component
        if let renderComponent = entity?.component(
            ofType: RenderComponent.self
        ) {
            renderComponent.node.position = _position
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
