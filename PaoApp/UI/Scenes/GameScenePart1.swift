//
//  GameScenePart1.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 19/05/26.
//

import Foundation
import SpriteKit
import UIKit
import GameplayKit

extension GameScene {
    //MARK: - Setup Assets
    func setupAssets() {
        backgroundNode = SKSpriteNode(imageNamed: "backgroundNode")
        bgCheckeredNode = SKSpriteNode(imageNamed: "bgCheckeredNode")
        greenBlockNode = SKSpriteNode(imageNamed: "greenBlockNode")
        pinkBlockNode = SKSpriteNode(imageNamed: "pinkBlockNode")
        yellowBlockNode = SKSpriteNode(imageNamed: "yellowBlockNode")
        pandaNode = SKSpriteNode(imageNamed: "pandaNode")
        collectBakpaoNode = SKSpriteNode(imageNamed: "bakpaoNode")
        bakpaoNode = SKSpriteNode(imageNamed: "bakpaoNode")
        pandaFrames = [
            SKTexture(imageNamed: "panda_1"),
            SKTexture(imageNamed: "panda_2")
        ]
    }
    
    // MARK: - Layout (screen-adaptive)
    func loadOverlayFromSKS() {
        
        guard let scene = SKScene(fileNamed: "GameScene") else {
            print("GameScene.sks not found")
            return
        }
        
        guard let overlayNode = scene.childNode(withName: "//overlayNode") else {
            print("overlayNode not found")
            return
        }
        
        let overlayCopy = overlayNode.copy() as! SKNode
        
        overlayCopy.position = CGPoint(
            x: gridOrigin.x + gridW / 2,
            y: gridOrigin.y + gridH / 2 + 100
        )
        
        overlayCopy.zPosition = -3
        
        addChild(overlayCopy)
        
        bgBrownNode = overlayCopy.childNode(withName: "//bgBrownNode") as? SKSpriteNode
        gameFrameNode = overlayCopy.childNode(withName: "//gameFrameNode") as? SKSpriteNode
        
        print("bgBrownNode:", bgBrownNode != nil)
        print("frameNode:", gameFrameNode != nil)
        
    }
    func computeLayout(in view: SKView) {
        
        gridW = frame.width * 0.94
        cell = gridW / CGFloat(GameConstants.cols)
        
        gridH = cell * CGFloat(GameConstants.blockRows + 1)
        
        // sementara center dulu
        let gridX = frame.midX - gridW / 2
        let gridY = frame.midY - gridH / 2 - 50
        
        gridOrigin = CGPoint(
            x: gridX,
            y: gridY
        )
        
        shootX = frame.midX
        
        // posisi shooter
        shootY = cellCenter(
            col: 0,
            row: GameConstants.blockRows
        ).y
    }
    
    func configureWalls() {
        
    }
    
    func configureBlock() {
        let block = BlockEntity(type: .normal, health: 5, ballCount: 3, cell: 3.0)
        entityManager.add(block)
    }
    
//    override func update(_ currentTime: TimeInterval) {
//        let deltaTime = currentTime - lastUpdateTimeInterval
//        lastUpdateTimeInterval = currentTime
//        
//        entityManager.update(deltaTime)
//        
//    }
}
