//
//  PauseSettingScene.swift
//  PaoApp
//
//  Created by Edward Geraldo Kristian on 20/05/26.
//

import SpriteKit

class PauseSettingScene: SKScene {

    // 1. The Closures (Bridging back to SwiftUI)
    var onResume: (() -> Void)?
    var onQuit: (() -> Void)?

    // 2. Button State Tracking (Optional, for visual Polish)
    private var isResumePressed = false
    private var isQuitPressed = false
    private var buttonOriginalScale: CGFloat = 1.0
    
    var currentScore: Int = 0
    var highScore: Int = 0

    override func didMove(to view: SKView) {
        // You can add wobble or pulse animations here just like your HomeScene!
        // For example, finding the resume button to store its original scale:
        if let resumeBtn = childNode(withName: "//resumeButtonNode") {
            buttonOriginalScale = resumeBtn.xScale
        }
        let scoreLbl = SKLabelNode(fontNamed: "Melon-Pop")
          scoreLbl.text = "High Score:"
          scoreLbl.fontSize = 32
          scoreLbl.fontColor = UIColor(red: 92/255, green: 53/255, blue: 22/255, alpha: 1)
          scoreLbl.position = CGPoint(x: frame.midX, y: frame.midY + 100)  // tune y to fit your modal
          scoreLbl.zPosition = 10
          addChild(scoreLbl)

          let highLbl = SKLabelNode(fontNamed: "Melon-Pop")
          highLbl.text = "\(highScore)"
          highLbl.fontSize = 26
          highLbl.fontColor = UIColor(red: 233/255, green: 92/255, blue: 107/255, alpha: 1)
          highLbl.position = CGPoint(x: frame.midX, y: frame.midY + 40)  // tune y to fit your modal
          highLbl.zPosition = 10
          addChild(highLbl)
    }

    // 3. Catching the Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Find ALL nodes at the tapped location
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            // Check the names matching your .sks file
            if node.name == "resumeButtonNode" {
                // Add a little visual shrink effect when tapped
                node.run(SKAction.scale(to: buttonOriginalScale * 0.9, duration: 0.1))
                isResumePressed = true
            } else if node.name == "quitButtonNode" {
                node.run(SKAction.scale(to: buttonOriginalScale * 0.9, duration: 0.1))
                isQuitPressed = true
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Find the buttons to reset their scale
        let resumeBtn = childNode(withName: "//resumeButtonNode")
        let quitBtn = childNode(withName: "//quitButtonNode")
        
        // Reset visual scale
        resumeBtn?.run(SKAction.scale(to: buttonOriginalScale, duration: 0.1))
        quitBtn?.run(SKAction.scale(to: buttonOriginalScale, duration: 0.1))
        
        // Trigger the actual SwiftUI closures if they were pressed
        if isResumePressed {
            onResume?()
            isResumePressed = false
        }
        
        if isQuitPressed {
            onQuit?()
            isQuitPressed = false
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If the user drags their finger off the button, cancel the press
        touchesEnded(touches, with: event)
    }
}
