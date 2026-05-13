//
//  RoverComponent.swift
//  PaoApp
//
// Types moved to MovementSystem.swift — do not add to Xcode project.

import GameplayKit

// MARK: - RoverComponent

// Holds horizontal movement state for rover-type blocks.
// Read and written by MovementSystem every frame.
class RoverComponent: GKComponent {
    var direction: Int   // 1 = moving right, -1 = moving left
    var isStuck: Bool = false  // true when blocked on both sides

    init(direction: Int = Bool.random() ? 1 : -1) {
        self.direction = direction
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
