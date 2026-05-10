//
//  HealthComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit

class HealthComponent: GKComponent {
    var health: Int

    func hit() {
        self.health -= 1
    }

    init(
        _ health: Int,
    ) {
        self.health = health

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
