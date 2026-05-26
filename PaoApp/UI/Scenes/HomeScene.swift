//
//  HomeScene.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 19/05/26.
//

import SpriteKit

class HomeScene: SKScene {

    var onPlayTapped: (() -> Void)?

    private var isButtonPressed = false
    private var buttonOriginalScale: CGFloat = 1.0

    override func didMove(to view: SKView) {
        //To start BGM everytime the game opens
        SoundManager.shared.playBGM(track: .mainTheme)
        if let button = childNode(withName: "HomeScreenPlayButton") {
            buttonOriginalScale = button.xScale
        }
        startLogoWobble()
        startButtonPulse()
    }

    // MARK: - Logo Animation

    private func startLogoWobble() {
        guard let logo = childNode(withName: "HomeScreenLogo") else { return }

        let angle: CGFloat = .pi / 72  // 5 degrees

        let tiltRight = SKAction.rotate(toAngle: angle, duration: 0.5, shortestUnitArc: true)
        tiltRight.timingMode = .easeInEaseOut

        let tiltLeft = SKAction.rotate(toAngle: -angle, duration: 0.9, shortestUnitArc: true)
        tiltLeft.timingMode = .easeInEaseOut

        let center = SKAction.rotate(toAngle: 0, duration: 0.4, shortestUnitArc: true)
        center.timingMode = .easeInEaseOut

        let pause = SKAction.wait(forDuration: 5.0)

        logo.run(.repeatForever(.sequence([tiltRight, tiltLeft, center, pause])))
    }

    // MARK: - Button Idle Animation

    private func startButtonPulse() {
        guard let button = childNode(withName: "HomeScreenPlayButton") else { return }

        let grow = SKAction.scale(to: buttonOriginalScale * 1.06, duration: 1)
        grow.timingMode = .easeInEaseOut

        let shrink = SKAction.scale(to: buttonOriginalScale * 0.97, duration: 1)
        shrink.timingMode = .easeInEaseOut

        button.run(.repeatForever(.sequence([grow, shrink])), withKey: "pulse")
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let button = childNode(withName: "HomeScreenPlayButton"),
           button.contains(location) {
            isButtonPressed = true
            //SFX PLAY
            SoundManager.shared.playSFX(.playAndPause, on: self)
            button.removeAction(forKey: "pulse")
            button.run(.scale(to: buttonOriginalScale * 0.88, duration: 0.1), withKey: "press")
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isButtonPressed, let touch = touches.first else { return }
        let location = touch.location(in: self)

        guard let button = childNode(withName: "HomeScreenPlayButton") else { return }

        if !button.contains(location) {
            isButtonPressed = false
            let restore = SKAction.sequence([
                .scale(to: buttonOriginalScale, duration: 0.15),
                .run { self.startButtonPulse() }
            ])
            button.run(restore, withKey: "press")
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        guard let button = childNode(withName: "HomeScreenPlayButton") else { return }

        if isButtonPressed && button.contains(location) {
            isButtonPressed = false
            let restore = SKAction.sequence([
                .scale(to: buttonOriginalScale, duration: 0.1),
                .run { self.startButtonPulse() }
            ])
            button.run(restore, withKey: "press")
            onPlayTapped?()
        } else {
            isButtonPressed = false
            let restore = SKAction.sequence([
                .scale(to: buttonOriginalScale, duration: 0.1),
                .run { self.startButtonPulse() }
            ])
            button.run(restore, withKey: "press")
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isButtonPressed = false
        let restore = SKAction.sequence([
            .scale(to: buttonOriginalScale, duration: 0.15),
            .run { self.startButtonPulse() }
        ])
        childNode(withName: "HomeScreenPlayButton")?.run(restore, withKey: "press")
    }
}
