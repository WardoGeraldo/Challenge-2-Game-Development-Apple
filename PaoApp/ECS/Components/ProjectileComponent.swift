//
//  ProjectileComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 19/05/26.
//

import Foundation
import GameplayKit

class ProjectileComponent: GKComponent {
    var damage: Int

    init(
        _ damage: Int,
    ) {
        self.damage = damage

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
