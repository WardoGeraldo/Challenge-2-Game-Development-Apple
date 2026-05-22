//
//  AimLineEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 20/05/26.
//

import Foundation
import GameplayKit

class AimLineEntity: GKEntity {
    override init() {
        super.init()

        let node = AimLineNode()
        addComponent(RenderComponent(node))

        addComponent(
            TransformComponent(
                .zero
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
