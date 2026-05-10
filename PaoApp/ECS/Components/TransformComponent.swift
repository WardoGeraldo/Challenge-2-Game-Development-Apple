//
//  TransformComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit

class TransformComponent: GKComponent {
    var position: CGPoint

    // TODO: Should we use zRotation or constraints orient?
    //    var zRotation: CGFloat

    //  Accessing the parent's spritenode if any
    var spriteNode: SKNode? {
        return entity?.component(ofType: RenderComponent.self)?.node
            as? SKNode
    }

    init(_ position: CGPoint, _ zRotation: CGFloat) {
        self.position = position
        //        self.zRotation = zRotation

        super.init()

        spriteNode?.position = position
        //        spriteNode?.zRotation = zRotation
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        // Now 'entity' is not nil, so we can find the sibling sprite component
        if let renderComponent = entity?.component(
            ofType: RenderComponent.self
        ) {
            renderComponent.node.position = self.position
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
