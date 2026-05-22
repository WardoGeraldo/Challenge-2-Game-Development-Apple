//
//  GameState.swift
//  PaoApp
//
//  Created by Saujana Shafi on 12/05/26.
//

import Foundation
import GameplayKit
import SpriteKit

class GameState: GKState {
    // MARK: Properties

    /// A reference to the entity manager, used to alter the entity.
    let entityManager: EntityManager
    // MARK: Initialization

    init(
        _ entityManager: EntityManager,
    ) {
        self.entityManager = entityManager
    }

    // MARK: GKState overrides

    // MARK: Methods
}
