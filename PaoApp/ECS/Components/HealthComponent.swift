//
//  HealthComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit

// MARK: - HealthComponent

class HealthComponent: GKComponent {
    private(set) var health: Int
    let maxHealth: Int

    var isDead: Bool { health <= 0 }

    init(_ health: Int) {
        self.health    = health
        self.maxHealth = health
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var label: SKLabelNode

    //  Accessing the parent's spritenode if any
    var spriteNode: SKNode? {
        return entity?.component(ofType: RenderComponent.self)?.node
            as? SKNode
    }

    func hit(demage: Int = 1) {
        self.health -= demage
    }
}

// MARK: - BlockTypeComponent

// Stores the block's behavioural type (defined in BlockNodes.swift)
class BlockTypeComponent: GKComponent {
    let blockType: BlockType

        self.label = LabelNode(name: "healthLabel")

        super.init()

        self.label.text = String(self.health)
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        // Now 'entity' is not nil, so we can find the sibling sprite component
        if let renderComponent = entity?.component(
            ofType: RenderComponent.self
        ) {
            renderComponent.node.addChild(self.label)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
