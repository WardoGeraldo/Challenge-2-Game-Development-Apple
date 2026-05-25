//
//  HealthComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

//  HealthComponent.swift
import Foundation
import GameplayKit

enum BlockType {
    case low
    case medium
    case high
    case normal
    case triangle(flipped: Bool)
    case bomb
    case rover

    var isBomb: Bool {
        if case .bomb = self { return true }
        return false
    }

    var isRover: Bool {
        if case .rover = self { return true }
        return false
    }
}

class HealthComponent: GKComponent {
    private(set) var health: Int
    let maxHealth: Int
    var isDead: Bool { health <= 0 }

    init(_ health: Int) {
        self.health = health
        self.maxHealth = health
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @discardableResult
    func hit(demage: Int = 1) -> Bool {
        health -= demage
        return isDead
    }
}

class BlockTypeComponent: GKComponent {
    let blockType: BlockType

    init(_ type: BlockType) {
        self.blockType = type
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
