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

    // Decrements HP by 1; returns true if entity is now dead
    @discardableResult
    func hit() -> Bool {
        health = max(0, health - 1)
        return isDead
    }
}

// MARK: - BlockTypeComponent

// Stores the block's behavioural type (defined in BlockNodes.swift)
class BlockTypeComponent: GKComponent {
    let blockType: BlockType

    init(_ type: BlockType) {
        self.blockType = type
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
