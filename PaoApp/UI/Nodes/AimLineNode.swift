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

        self.strokeColor = .white
        self.lineWidth = kCell / 4
        self.lineCap = .round
        self.zPosition = 5

        self.name = "aimLine"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
