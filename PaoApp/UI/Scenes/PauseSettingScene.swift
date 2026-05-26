//
//  PauseSettingScene.swift
//  PaoApp
//
//  Created by Edward Geraldo Kristian on 20/05/26.
//

import SpriteKit

class PauseSettingScene: SKScene {

    var onResume: (() -> Void)?
    var onQuit: (() -> Void)?

    private var pressedResumeNode: SKNode?
    private var pressedQuitNode: SKNode?
    private var resumeOriginalXScale: CGFloat = 1.0
    private var resumeOriginalYScale: CGFloat = 1.0
    private var quitOriginalXScale: CGFloat = 1.0
    private var quitOriginalYScale: CGFloat = 1.0

    var currentScore: Int = 0
    var highScore: Int = 0

    override func didMove(to view: SKView) {
        let scoreBackground = makeRoundedBackground(size: CGSize(width: 210, height: 54))
        scoreBackground.position = CGPoint(x: frame.midX, y: frame.midY + 45)
        addChild(scoreBackground)

        let scoreLbl = SKLabelNode(fontNamed: "Melon-Pop")
        scoreLbl.text = "HIGHSCORE"
        scoreLbl.fontSize = 20
        scoreLbl.fontColor = UIColor(red: 92/255, green: 53/255, blue: 22/255, alpha: 1)
        scoreLbl.position = CGPoint(x: frame.midX, y: frame.midY + 80)
        scoreLbl.zPosition = 10
        addChild(scoreLbl)

        let highLbl = SKLabelNode(fontNamed: "Melon-Pop")
        highLbl.text = "\(highScore)"
        highLbl.fontSize = 34
        highLbl.fontColor = UIColor(red: 233/255, green: 92/255, blue: 107/255, alpha: 1)
        highLbl.position = CGPoint(x: frame.midX, y: frame.midY + 30)
        highLbl.zPosition = 10
        addChild(highLbl)
    }

    private func makeRoundedBackground(size: CGSize) -> SKShapeNode {
        let rect = SKShapeNode(rectOf: size, cornerRadius: 20)
        rect.fillColor = UIColor(red: 246/255, green: 231/255, blue: 197/255, alpha: 1)
        rect.strokeColor = .clear
        rect.zPosition = 9
        return rect
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        if let node = tappedNodes.first(where: { $0.name == "resumeButtonNode" }), pressedResumeNode == nil {
            pressedResumeNode = node
            resumeOriginalXScale = node.xScale
            resumeOriginalYScale = node.yScale
            node.run(SKAction.scaleX(to: resumeOriginalXScale * 0.9, y: resumeOriginalYScale * 0.9, duration: 0.1))
            SoundManager.shared.playSFX(.playAndPause, on: self)
        } else if let node = tappedNodes.first(where: { $0.name == "quitButtonNode" }), pressedQuitNode == nil {
            pressedQuitNode = node
            quitOriginalXScale = node.xScale
            quitOriginalYScale = node.yScale
            node.run(SKAction.scaleX(to: quitOriginalXScale * 0.9, y: quitOriginalYScale * 0.9, duration: 0.1))
            SoundManager.shared.playSFX(.playAndPause, on: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let hit = Set(nodes(at: location).compactMap { $0.name })

        if pressedResumeNode != nil, !hit.contains("resumeButtonNode") {
            pressedResumeNode?.run(SKAction.scaleX(to: resumeOriginalXScale, y: resumeOriginalYScale, duration: 0.1))
            pressedResumeNode = nil
        }

        if pressedQuitNode != nil, !hit.contains("quitButtonNode") {
            pressedQuitNode?.run(SKAction.scaleX(to: quitOriginalXScale, y: quitOriginalYScale, duration: 0.1))
            pressedQuitNode = nil
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let node = pressedResumeNode {
            node.run(SKAction.scaleX(to: resumeOriginalXScale, y: resumeOriginalYScale, duration: 0.1))
            pressedResumeNode = nil
            onResume?()
        }

        if let node = pressedQuitNode {
            node.run(SKAction.scaleX(to: quitOriginalXScale, y: quitOriginalYScale, duration: 0.1))
            pressedQuitNode = nil
            onQuit?()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let node = pressedResumeNode {
            node.run(SKAction.scaleX(to: resumeOriginalXScale, y: resumeOriginalYScale, duration: 0.1))
            pressedResumeNode = nil
        }

        if let node = pressedQuitNode {
            node.run(SKAction.scaleX(to: quitOriginalXScale, y: quitOriginalYScale, duration: 0.1))
            pressedQuitNode = nil
        }
    }
}
