//
//  GameScenePart4.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 19/05/26.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

extension GameScene {
    func animateAmmoGain(
        from worldPosition: CGPoint,
        oldCount: Int,
        newCount: Int
    ) {

        // Ukuran pickup asli
        let pickupSize = cell * 0.82

        // Ukuran HUD
        let hudSize = GameConstants.ballRadius * 1.75

        // Spawn di scene langsung
        guard let flying = collectBakpaoNode?.copy() as? SKSpriteNode else {
            return
        }

        flying.size = CGSize(
            width: pickupSize,
            height: pickupSize
        )

        flying.position = worldPosition
        flying.zPosition = 999

        addChild(flying)

        // ===== TARGET HUD POSITION =====

        let spacing: CGFloat

        if newCount <= 5 {
            spacing = hudSize * 0.72
        } else if newCount <= 10 {
            spacing = hudSize * 0.48
        } else {
            spacing = hudSize * 0.28
        }

        let maxWidth: CGFloat = 120

        let finalSpacing: CGFloat

        if newCount > 1 {
            finalSpacing = min(
                spacing,
                maxWidth / CGFloat(newCount - 1)
            )
        } else {
            finalSpacing = spacing
        }

        // Convert target HUD position → scene coordinate
        let localTarget = CGPoint(
            x: CGFloat(newCount - 1) * finalSpacing,
            y: CGFloat.random(in: -2...2)
        )

        let targetPos = ammoContainer.convert(
            localTarget,
            to: self
        )

        // ===== FALL DOWN =====

        let drop = SKAction.moveBy(
            x: 0,
            y: -140,
            duration: 0.75
        )

        drop.timingMode = .easeIn

        // Squash saat jatuh
        let squash = SKAction.sequence([

            .group([
                .scaleX(to: 1.18, duration: 0.10),
                .scaleY(to: 0.78, duration: 0.10)
            ]),

            .group([
                .scaleX(to: 1.0, duration: 0.12),
                .scaleY(to: 1.0, duration: 0.12)
            ])
        ])

        // ===== FLY TO HUD =====

        let fly = SKAction.move(
            to: targetPos,
            duration: 0.55
        )

        fly.timingMode = .easeInEaseOut

        let shrink = SKAction.resize(
            toWidth: hudSize,
            height: hudSize,
            duration: 0.55
        )

        shrink.timingMode = .easeOut

        let rotate = SKAction.rotate(
            byAngle: CGFloat.random(in: -0.8...0.8),
            duration: 0.55
        )

        // ===== POP =====

        let pop = SKAction.sequence([
            .scale(to: 1.2, duration: 0.08),
            .scale(to: 1.0, duration: 0.12)
        ])

        flying.run(.sequence([

            // Jatuh dulu
            .group([
                drop,
                squash
            ]),

            // Pause biar kerasa
            .wait(forDuration: 0.12),

            // Terbang ke HUD
            .group([
                fly,
                shrink,
                rotate
            ]),

            // Pop masuk HUD
            pop,

            .run { [weak self] in
                self?.updateAmmoIcons()
            },

            .removeFromParent()
        ]))
    }
    
    func updateAmmoContainerPosition(animated: Bool = true) {

        let target = CGPoint(
            x: shootX,
            y: shootY - 4
        )

        if animated {

            let move = SKAction.move(
                to: target,
                duration: 0.22
            )

            move.timingMode = .easeInEaseOut

            ammoContainer.run(move)

        } else {

            ammoContainer.position = target
        }
    }
    
    // MARK: - Shooter Marker

    func placeShooterMarker() {
        // Remove previous player entity
        if let prev = playerEntity {
            entityManager.remove(prev)
        }

        let node = PlayerNode(
            radius: GameConstants.ballRadius
        )
        node.position = CGPoint(x: shootX, y: shootY)

        let entity = PlayerEntity(node: node)
        entityManager.add(entity)
        playerEntity = entity
        guard let panda = pandaNode else { return }
            let target = CGPoint(x: shootX, y: shootY + 30)
            if panda.parent == nil {
                panda.size = CGSize(width: cell * 1.3, height: cell * 1.3)
                panda.zPosition = 5
                panda.position = target
                addChild(panda)
            } else {
                let move = SKAction.move(to: target, duration: 0.22)
                move.timingMode = .easeInEaseOut
                panda.run(move)
            }
    }
}
