//
//  BlockEntity.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import SpriteKit

class BlockNode: SKNode {
    init(scale: CGFloat) {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// TODO: Other block variants
class BlockShapeNode: SKShapeNode {
    /// Use scale to handle different size of screens
    init(scale: CGFloat) {
        super.init()

        // TODO: Implement Block Shape Node attributes here
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class BlockPhysicsBody: SKPhysicsBody {
    override init() {
        super.init()

        // TODO: Implement Block Physics Body attributes here
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
