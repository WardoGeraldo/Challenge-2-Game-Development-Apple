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
    // MARK: - Assets
    // Load all reusable sprite templates. These are copied (not used directly) when building the scene.
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
    
    // MARK: - Overlay
    // Loads the visual overlay (frame + background panel) from GameScene.sks and pins it to the grid.
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
        bakpaoCountFrameNode = overlayCopy.childNode(withName: "//bakpaoCountFrameNode") as? SKSpriteNode
        pauseFrameNode       = overlayCopy.childNode(withName: "//pauseFrameNode") as? SKSpriteNode
        pauseButtonNode      = overlayCopy.childNode(withName: "//pauseButtonNode") as? SKSpriteNode
        
        print("bgBrownNode:", bgBrownNode != nil)
        print("frameNode:", gameFrameNode != nil)
        print("bakpaoCountFrameNode:", bakpaoCountFrameNode != nil)
        print("pauseFrameNode:", pauseFrameNode != nil)
        print("pauseButtonNode:", pauseButtonNode != nil)
    }
    
    // MARK: - Walls
    // Creates invisible physics edges on left, right, and top. No floor — balls fall back to shootY.
    func buildWalls() {

        let left   = gridOrigin.x
        let right  = gridOrigin.x + gridW
        let bottom = gridOrigin.y
        let top    = gridOrigin.y + gridH

        let edges: [(CGPoint, CGPoint)] = [

            // LEFT
            (CGPoint(x: left, y: bottom),
             CGPoint(x: left, y: top)),

            // RIGHT
            (CGPoint(x: right, y: bottom),
             CGPoint(x: right, y: top)),

            // TOP
            (CGPoint(x: left, y: top),
             CGPoint(x: right, y: top))
        ]

        for (a, b) in edges {
            let wall = SKNode()
            wall.physicsBody = SKPhysicsBody(edgeFrom: a, to: b)
            wall.physicsBody?.friction = 0
            wall.physicsBody?.restitution = 1
            wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
            wall.physicsBody?.collisionBitMask = PhysicsCategory.ball
            wall.physicsBody?.contactTestBitMask = PhysicsCategory.ball
            addChild(wall)
        }
    }
    
    // MARK: - Background
    // Places the full-screen background image and the checkered grid panel.
    func buildBackground() {
        backgroundColor = .black
        if let bg = backgroundNode?.copy() as? SKSpriteNode {
            
            bg.position = CGPoint(
                x: frame.midX,
                y: frame.midY
            )
            
            bg.size = frame.size
            
            bg.zPosition = -100
            
            addChild(bg)
        }
  
        if let grid = bgCheckeredNode?.copy() as? SKSpriteNode {
            self.bgCheckeredNode = grid
        
            let textureSize = grid.texture?.size() ?? CGSize(
                width: 100,
                height: 100
            )
            let targetWidth = frame.width * 0.94
            let aspectRatio =
            textureSize.height / textureSize.width
            
            let targetHeight =
            targetWidth * aspectRatio
            
            gridW = targetWidth
            gridH = targetHeight
            
            grid.anchorPoint = CGPoint(x: 0, y: 0)
            grid.position = gridOrigin
            grid.size = CGSize(
                width: gridW,
                height: gridH
            )
            grid.zPosition = 0
            grid.name = "grid"
            
            addChild(grid)
        }
    }
}
