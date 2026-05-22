//
//  AimLineNode.swift
//  PaoApp
//
//  Created by Saujana Shafi on 20/05/26.
//

import Foundation
import SpriteKit

class AimLineNode: SKShapeNode {
    override init() {
        super.init()

        strokeColor = .white
        lineWidth = 2
        lineCap = .round
        zPosition = 5
        name = "aim"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
