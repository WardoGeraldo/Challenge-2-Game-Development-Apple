//
//  LabelNode.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 13/05/26.
//

import Foundation
import SpriteKit

class LabelNode: SKLabelNode {
    init(name:String){
        super.init()
        
        self.name = name
        self.fontSize = 16
        self.fontColor = .white
        self.fontName = "AvenirNext-Bold"

        // Center the label
        self.verticalAlignmentMode = .center
        self.horizontalAlignmentMode = .center
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
