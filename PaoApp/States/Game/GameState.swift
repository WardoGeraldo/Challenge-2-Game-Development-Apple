//
//  GameStateContext.swift
//  PaoApp
//
//  Created by Axel on 13/05/26.
//

import CoreGraphics
import Foundation
import GameplayKit
import SpriteKit

// States communicate with GameScene through this protocol to stay decoupled.
class GameState: GKState {
    // MARK: Properties

    /// A reference to the entity manager, used to alter the entity.
    let entityManager: EntityManager

    // MARK: Initialization

    init(_ entityManager: EntityManager) {
        self.entityManager = entityManager
    }

    // MARK: GKState overrides

    // MARK: Methods
}
