//
//  NewHighScoreModalScene.swift
//  PaoApp
//
//  Created by rasyel on 20/05/26.
//

import SpriteKit

final class NewHighScoreModalScene: SKScene {

    // MARK: - Nodes
    private var newHighScoreModalNode: SKSpriteNode?
    private var xButtonNode: SKSpriteNode?
    private var playAgainButtonNode: SKSpriteNode?
    private var newFrameNode: SKSpriteNode?

    // MARK: - Score
    private var scoreLabel: SKLabelNode?
    private var highscoreLabel: SKLabelNode?

    var score: Int = 0
    var highscore: Int = 0

    // MARK: - Callbacks
    var onClose: (() -> Void)?
    var onPlayAgain: (() -> Void)?

    // MARK: - Press State
    private var isClosePressed = false
    private var isPlayAgainPressed = false

    // MARK: - Original State
    private var originalModalPosition: CGPoint = .zero
    private var originalModalSize: CGSize = .zero

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        setupNodes()
        setupScoreTexts()
        animateModalIn()
    }

    // MARK: - Setup

    private func setupNodes() {
        newHighScoreModalNode = childNode(withName: "//newHighscoreModalNode") as? SKSpriteNode
        xButtonNode = childNode(withName: "//xButtonNode") as? SKSpriteNode
        playAgainButtonNode = childNode(withName: "//playAgainButtonNode") as? SKSpriteNode
        newFrameNode = childNode(withName: "//newFrameNode") as? SKSpriteNode

        if let modal = newHighScoreModalNode {
            originalModalPosition = modal.position
            originalModalSize = modal.size
            modal.alpha = 0
        }
    }

    private func makeRoundedBackground(size: CGSize) -> SKShapeNode {
        let rect = SKShapeNode(rectOf: size, cornerRadius: 28)
        rect.fillColor = UIColor(red: 246/255, green: 231/255, blue: 197/255, alpha: 1)
        rect.strokeColor = .clear
        rect.zPosition = 998
        return rect
    }

    private func setupScoreTexts() {
        guard let modal = newHighScoreModalNode else { return }

        let scoreBackground = makeRoundedBackground(size: CGSize(width: 500, height: 120))
        scoreBackground.position = CGPoint(x: 0, y: 310)
        modal.addChild(scoreBackground)

        let scoreTitle = SKLabelNode(fontNamed: "Melon-Pop")
        scoreTitle.text = "SCORE"
        scoreTitle.fontSize = 42
        scoreTitle.fontColor = UIColor(red: 92/255, green: 53/255, blue: 22/255, alpha: 1)
        scoreTitle.position = CGPoint(x: 0, y: 390)
        scoreTitle.zPosition = 1000
        modal.addChild(scoreTitle)

        scoreLabel = SKLabelNode(fontNamed: "Melon-Pop")
        scoreLabel?.text = "\(score)"
        scoreLabel?.fontSize = 80
        scoreLabel?.fontColor = UIColor(red: 233/255, green: 92/255, blue: 107/255, alpha: 1)
        scoreLabel?.position = CGPoint(x: 0, y: 280)
        scoreLabel?.zPosition = 1000
        if let scoreLabel { modal.addChild(scoreLabel) }

        let highscoreBackground = makeRoundedBackground(size: CGSize(width: 500, height: 120))
        highscoreBackground.position = CGPoint(x: 0, y: 80)
        modal.addChild(highscoreBackground)

        let highscoreTitle = SKLabelNode(fontNamed: "Melon-Pop")
        highscoreTitle.text = "HIGHSCORE"
        highscoreTitle.fontSize = 42
        highscoreTitle.fontColor = UIColor(red: 92/255, green: 53/255, blue: 22/255, alpha: 1)
        highscoreTitle.position = CGPoint(x: 0, y: 160)
        highscoreTitle.zPosition = 999
        modal.addChild(highscoreTitle)

        highscoreLabel = SKLabelNode(fontNamed: "Melon-Pop")
        highscoreLabel?.text = "\(highscore)"
        highscoreLabel?.fontSize = 80
        highscoreLabel?.fontColor = UIColor(red: 92/255, green: 53/255, blue: 22/255, alpha: 1)
        highscoreLabel?.position = CGPoint(x: 0, y: 50)
        highscoreLabel?.zPosition = 999
        if let highscoreLabel { modal.addChild(highscoreLabel) }
    }

    // MARK: - Animations

    private func animateModalIn() {
        SoundManager.shared.playSFX(.highScore, on: self)

        guard let modal = newHighScoreModalNode else { return }
        let originalXScale = modal.xScale
        let originalYScale = modal.yScale

        modal.setScale(0.92)
        modal.alpha = 0

        let fade = SKAction.fadeIn(withDuration: 0.2)
        let scaleUp = SKAction.scaleX(to: originalXScale, y: originalYScale, duration: 0.2)
        scaleUp.timingMode = .easeOut
        modal.run(.group([fade, scaleUp]))
    }

    private func dismissModal(completion: (() -> Void)? = nil) {
        guard let modal = newHighScoreModalNode else { completion?(); return }

        let fade = SKAction.fadeOut(withDuration: 0.16)
        let scale = SKAction.scale(to: 0.94, duration: 0.16)
        scale.timingMode = .easeInEaseOut

        modal.run(.sequence([.group([fade, scale]), .run { completion?() }]))
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)

        if touchedNode.name == "xButtonNode" || touchedNode.parent?.name == "xButtonNode" {
            isClosePressed = true
            xButtonNode?.run(SKAction.scale(to: 0.92, duration: 0.05))
            SoundManager.shared.playSFX(.playAndPause, on: self)
        }

        if touchedNode.name == "playAgainButtonNode" || touchedNode.parent?.name == "playAgainButtonNode" {
            isPlayAgainPressed = true
            playAgainButtonNode?.run(SKAction.scale(to: 0.92, duration: 0.05))
            SoundManager.shared.playSFX(.playAndPause, on: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isClosePressed, let btn = xButtonNode, !btn.contains(location) {
            isClosePressed = false
            btn.run(SKAction.scale(to: 1.0, duration: 0.08))
        }

        if isPlayAgainPressed, let btn = playAgainButtonNode, !btn.contains(location) {
            isPlayAgainPressed = false
            btn.run(SKAction.scale(to: 1.0, duration: 0.08))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isClosePressed {
            isClosePressed = false
            xButtonNode?.run(SKAction.scale(to: 1.0, duration: 0.08))
            dismissModal { [weak self] in self?.onClose?() }
        }

        if isPlayAgainPressed {
            isPlayAgainPressed = false
            playAgainButtonNode?.run(SKAction.scale(to: 1.0, duration: 0.08))
            dismissModal { [weak self] in self?.onPlayAgain?() }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isClosePressed {
            isClosePressed = false
            xButtonNode?.run(SKAction.scale(to: 1.0, duration: 0.08))
        }

        if isPlayAgainPressed {
            isPlayAgainPressed = false
            playAgainButtonNode?.run(SKAction.scale(to: 1.0, duration: 0.08))
        }
    }
}
