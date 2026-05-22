//
//  ConsumableComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

class ConsumableComponent: GKComponent {
    let entityToAdd: GKEntity

    init(
        entityToAdd: GKEntity,
    ) {
        self.entityToAdd = entityToAdd

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
