//
//  HealthComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit
import SpriteKit

// MARK: - HealthComponent

class HealthComponent: GKComponent {
    private(set) var health: Int
    let maxHealth: Int

    var isDead: Bool { health <= 0 }

    let label: LabelNode

    init(_ health: Int) {
        self.health    = health
        self.maxHealth = health
        self.label     = LabelNode(name: "hp")
        super.init()
        self.label.text      = String(health)
        self.label.fontName  = GameConstants.fontName
        self.label.fontSize  = 16
        self.label.zPosition = 2
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        if let renderComponent = entity?.component(ofType: RenderComponent.self) {
            renderComponent.node.addChild(self.label)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    func hit() -> Bool {
        health = max(0, health - 1)
        label.text = String(health)
        return isDead
    }
}


