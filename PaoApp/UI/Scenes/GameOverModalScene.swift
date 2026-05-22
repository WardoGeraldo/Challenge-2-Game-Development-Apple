//
//  GameOverModalScene.swift
//  PaoApp
//
//  Created by rasyel on 20/05/26.
//

import SpriteKit

final class GameOverModalScene: SKScene {
    // MARK: - Nodes

    private var oopsModalNode: SKSpriteNode?
    private var xButtonNode: SKSpriteNode?
    private var playAgainButtonNode: SKSpriteNode?
    
    //MARK: - Score
    private var scoreLabel: SKLabelNode?
    private var highscoreLabel: SKLabelNode?

    var score: Int = 0
    var highscore: Int = 0

    // MARK: - Callbacks

    var onClose: (() -> Void)?
    var onPlayAgain: (() -> Void)?

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

        oopsModalNode =
            childNode(withName: "//oopsModalNode")
            as? SKSpriteNode

        xButtonNode =
            childNode(withName: "//xButtonNode")
            as? SKSpriteNode

        playAgainButtonNode =
            childNode(withName: "//playAgainButtonNode")
            as? SKSpriteNode

        if let modal = oopsModalNode {

            originalModalPosition = modal.position
            originalModalSize = modal.size
            modal.alpha = 0
        }
        
    }
    
    private func makeRoundedBackground(
        size: CGSize
    ) -> SKShapeNode {

        let rect = SKShapeNode(
            rectOf: size,
            cornerRadius: 28
        )

        rect.fillColor = UIColor(
            red: 246/255,
            green: 231/255,
            blue: 197/255,
            alpha: 1
        )

        rect.strokeColor = .clear

        rect.zPosition = 998

        return rect
    }
    
    private func setupScoreTexts() {

        guard let modal = oopsModalNode else { return }

        let scoreBackground = makeRoundedBackground(
            size: CGSize(
                width: 500,
                height: 120
            )
        )

        scoreBackground.position = CGPoint(
            x: 0,
            y: 310
        )

        modal.addChild(scoreBackground)

        //
        // ===== SCORE TITLE =====
        //

        let scoreTitle = SKLabelNode(fontNamed: "Melon-Pop")

        scoreTitle.text = "SCORE"

        scoreTitle.fontSize = 42

        scoreTitle.fontColor = UIColor(
            red: 92/255,
            green: 53/255,
            blue: 22/255,
            alpha: 1
        )

        scoreTitle.position = CGPoint( x: 0, y: 390 )

        scoreTitle.zPosition = 999

        modal.addChild(scoreTitle)

        //
        // ===== SCORE VALUE =====
        //

        scoreLabel = SKLabelNode(fontNamed: "Melon-Pop")

        scoreLabel?.text = "\(score)"

        scoreLabel?.fontSize = 80

        scoreLabel?.fontColor = UIColor(
            red: 92/255,
            green: 53/255,
            blue: 22/255,
            alpha: 1
        )

        scoreLabel?.position = CGPoint( x: 0, y: 280 )

        scoreLabel?.zPosition = 999

        if let scoreLabel {
            modal.addChild(scoreLabel)
        }

        //
        // ===== HIGHSCORE BACKGROUND =====
        //

        let highscoreBackground = makeRoundedBackground(
            size: CGSize(
                width: 500,
                height: 120
            )
        )

        highscoreBackground.position = CGPoint(
            x: 0,
            y: 80
        )

        modal.addChild(highscoreBackground)

        //
        // ===== HIGHSCORE TITLE =====
        //

        let highscoreTitle = SKLabelNode(fontNamed: "Melon-Pop")

        highscoreTitle.text = "HIGHSCORE"

        highscoreTitle.fontSize = 42

        highscoreTitle.fontColor = UIColor(
            red: 92/255,
            green: 53/255,
            blue: 22/255,
            alpha: 1
        )

        highscoreTitle.position = CGPoint(
            x: 0,
            y: 160
        )

        highscoreTitle.zPosition = 999

        modal.addChild(highscoreTitle)

        //
        // ===== HIGHSCORE VALUE =====
        //

        highscoreLabel = SKLabelNode(fontNamed: "Melon-Pop")

        highscoreLabel?.text = "\(highscore)"

        highscoreLabel?.fontSize = 80

        highscoreLabel?.fontColor = UIColor(
            red: 233/255,
            green: 92/255,
            blue: 107/255,
            alpha: 1
        )

        highscoreLabel?.position = CGPoint(
            x: 0,
            y: 50
        )

        highscoreLabel?.zPosition = 999

        if let highscoreLabel {
            modal.addChild(highscoreLabel)
        }
    }
    
    // MARK: - Animations

    private func animateModalIn() {

        guard let modal = oopsModalNode else { return }

        let originalXScale = modal.xScale
        let originalYScale = modal.yScale

        modal.setScale(0.92)
        modal.alpha = 0

        let fade = SKAction.fadeIn(
            withDuration: 0.2
        )

        let scaleUp = SKAction.scaleX(
            to: originalXScale,
            y: originalYScale,
            duration: 0.2
        )

        scaleUp.timingMode = .easeOut

        modal.run(.group([
            fade,
            scaleUp
        ]))
    }

    private func animateButtonPress(_ node: SKNode) {
        let press = SKAction.sequence([
            .scale(to: 0.92, duration: 0.05),
            .scale(to: 1.0, duration: 0.08)
        ])

        node.run(press)
    }

    private func dismissModal(
        completion: (() -> Void)? = nil
    ) {

        guard let modal = oopsModalNode else {
            completion?()
            return
        }

        let fade = SKAction.fadeOut(
            withDuration: 0.16
        )

        let scale = SKAction.scale(
            to: 0.94,
            duration: 0.16
        )

        scale.timingMode = .easeInEaseOut

        modal.run(.sequence([

            .group([
                fade,
                scale
            ]),

            .run {
                completion?()
            }
        ]))
    }

    // MARK: - Touches

    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        guard let touch = touches.first else {
            return
        }

        let location = touch.location(in: self)

        let touchedNode = atPoint(location)

        if touchedNode.name == "xButtonNode"
            || touchedNode.parent?.name == "xButtonNode" {

            if let xButtonNode {

                animateButtonPress(xButtonNode)
            }

            dismissModal { [weak self] in

                self?.onClose?()
            }
        }

        if touchedNode.name == "playAgainButtonNode"
            || touchedNode.parent?.name == "playAgainButtonNode" {

            if let playAgainButtonNode {
                animateButtonPress(playAgainButtonNode)
            }

            dismissModal { [weak self] in
                self?.onPlayAgain?()
            }
        }
    }
}
