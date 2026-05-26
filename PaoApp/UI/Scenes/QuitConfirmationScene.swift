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

    private var yesNode: SKNode?
    private var noNode: SKNode?
    private var yesOriginalScale: CGFloat = 1.0
    private var noOriginalScale: CGFloat = 1.0
    private var isYesPressed = false
    private var isNoPressed = false

    override func didMove(to view: SKView) {
        yesNode = childNode(withName: "//yesButtonNode")
        noNode = childNode(withName: "//noButtonNode")
        yesOriginalScale = yesNode?.xScale ?? 1.0
        noOriginalScale = noNode?.xScale ?? 1.0
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let hit = Set(nodes(at: location).compactMap { $0.name })

        if hit.contains("yesButtonNode"), !isYesPressed {
            isYesPressed = true
            yesNode?.run(SKAction.scale(to: yesOriginalScale * 0.9, duration: 0.1))
            SoundManager.shared.playSFX(.playAndPause, on: self)
        } else if hit.contains("noButtonNode"), !isNoPressed {
            isNoPressed = true
            noNode?.run(SKAction.scale(to: noOriginalScale * 0.9, duration: 0.1))
            SoundManager.shared.playSFX(.playAndPause, on: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let hit = Set(nodes(at: location).compactMap { $0.name })

        if isYesPressed, !hit.contains("yesButtonNode") {
            isYesPressed = false
            yesNode?.run(SKAction.scale(to: yesOriginalScale, duration: 0.1))
        }

        if isNoPressed, !hit.contains("noButtonNode") {
            isNoPressed = false
            noNode?.run(SKAction.scale(to: noOriginalScale, duration: 0.1))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isYesPressed {
            isYesPressed = false
            yesNode?.run(SKAction.scale(to: yesOriginalScale, duration: 0.1))
            onConfirm?()
        }

        if isNoPressed {
            isNoPressed = false
            noNode?.run(SKAction.scale(to: noOriginalScale, duration: 0.1))
            onCancel?()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isYesPressed {
            isYesPressed = false
            yesNode?.run(SKAction.scale(to: yesOriginalScale, duration: 0.1))
        }

        if isNoPressed {
            isNoPressed = false
            noNode?.run(SKAction.scale(to: noOriginalScale, duration: 0.1))
        }
    }
}
