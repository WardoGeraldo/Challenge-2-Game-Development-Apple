//
//  BlockTypeComponent.swift
//  PaoApp
//
// Types moved to HealthComponent.swift and BlockNodes.swift — do not add to Xcode project.

import GameplayKit

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
