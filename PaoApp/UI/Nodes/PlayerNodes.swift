//
//  PlayerNodes.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import SpriteKit

class PlayerNode: SKNode {
    init(scale: CGFloat) {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PlayerShapeNode: SKShapeNode {
    init(scale: CGFloat) {
        super.init()

        let size = CGSize(width: kCell * scale, height: kCell * scale)
        let rect = CGRect(
            x: -size.width / 2,
            y: -size.height / 2,
            width: size.width,
            height: size.height
        )

        self.path = CGPath(
            roundedRect: rect,
            cornerWidth: 8 * scale,
            cornerHeight: 8 * scale,
            transform: nil
        )

        self.fillColor = .blue
        self.strokeColor = .white

        self.lineWidth = 2
        self.name = "player"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PlayerSpriteNode: SKSpriteNode {
    init(scale: CGFloat) {
        let size = CGSize(width: kCell * scale, height: kCell * scale)

        super.init(
            texture: SKTexture(imageNamed: "pandaNode"),
            color: .clear,
            size: size,
        )

        self.name = "player"

        self.zPosition = 4
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
