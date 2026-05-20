//
//  QuitConfirmationScene.swift
//  PaoApp
//
//  Created by Edward Geraldo Kristian on 20/05/26.
//

import Foundation
import SpriteKit

class QuitConfirmationScene: SKScene {
    
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    
    private var isYesPressed = false
    private var isNoPressed = false
    private var buttonOriginalScale: CGFloat = 1.0
    
    override func didMove(to view: SKView) {
        if let yesBtn = childNode(withName: "//yesButtonNode") {
            buttonOriginalScale = yesBtn.xScale
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "yesButtonNode" {
                node.run(SKAction.scale(to: buttonOriginalScale * 0.9, duration: 0.1))
                isYesPressed = true
            } else if node.name == "noButtonNode" {
                node.run(SKAction.scale(to: buttonOriginalScale * 0.9, duration: 0.1))
                isNoPressed = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let yesBtn = childNode(withName: "//yesButtonNode")
        let noBtn = childNode(withName: "//noButtonNode")
        
        yesBtn?.run(SKAction.scale(to: buttonOriginalScale, duration: 0.1))
        noBtn?.run(SKAction.scale(to: buttonOriginalScale, duration: 0.1))
        
        if isYesPressed {
            onConfirm?()
            isYesPressed = false
        }
        
        if isNoPressed {
            onCancel?()
            isNoPressed = false
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}
