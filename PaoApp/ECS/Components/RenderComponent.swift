//
//  RenderComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import GameplayKit

class RenderComponent: GKComponent {
    var node: SKNode

    init(_ node: SKNode) {
        self.node = node

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
