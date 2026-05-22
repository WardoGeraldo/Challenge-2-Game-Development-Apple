//
//  HealthComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit

class HealthComponent: GKComponent {
    private var _health: Int

    var health: Int {
        get {
            _health
        }
        set {
            _health = newValue
            label.text = String(self.health)
        }
    }

    var label: SKLabelNode

    //  Accessing the parent's spritenode if any
    var spriteNode: SKNode? {
        return entity?.component(ofType: RenderComponent.self)?.node
            as? SKNode
    }

    func hit(damage: Int = 1) {
        self.health -= damage
    }

    init(
        _ health: Int,
    ) {
        self._health = health

        self.label = LabelNode(name: "healthLabel")

        super.init()
        
        self.health = health
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
