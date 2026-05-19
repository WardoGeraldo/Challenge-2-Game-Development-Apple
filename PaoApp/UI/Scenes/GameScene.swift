//
//  GameScene.swift
//  PaoApp
//
//  Created by Saujana Shafi on 27/04/26.
//
import SpriteKit
import UIKit
import GameplayKit

// MARK: - GameScene
// Orchestrates ECS entities, systems, and game state machine.
// Handles physics contacts and gesture input; delegates logic to dedicated systems.
final class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Layout (computed dynamically from screen size)
    var cell:       CGFloat = 44
    let gap: CGFloat = 0
    var step: CGFloat { cell }
    var gridOrigin: CGPoint = .zero
    var gridW:      CGFloat = 0
    var gridH:      CGFloat = 0
    var shootY:     CGFloat = 0
    var shootX:     CGFloat = 0
    var visualBlockSize: CGFloat {
        cell * 0.78
    }
    var playableGridWidth: CGFloat {
        cell * CGFloat(GameConstants.cols)
    }
    
    var playableGridHeight: CGFloat {
        cell * CGFloat(GameConstants.blockRows)
    }
    var playAreaRect: CGRect {
        CGRect(
            x: gridOrigin.x,
            y: gridOrigin.y,
            width: gridW,
            height: gridH
        )
    }
    var playAreaInset: CGFloat {
        cell * 0.25
    }
    
    // MARK: - Game State
    var ballCount     = GameConstants.initialBallCount
    var turnNumber    = 0
    var portalCharges = 0
    
    // Update time
    var lastUpdateTimeInterval: TimeInterval = 0
    
    var score: Int = 0
    // Volley tracking
    var volleyTotal:  Int      = 0
    var volleyLanded: Int      = 0
    //    var firstLandX:   CGFloat? = nil
    var landedPositions: [CGFloat] = []
    var shotAngle:    CGFloat  = .pi / 2
    var lastDT:       TimeInterval = 0
    
    // Portal warp band positions (set when portal volley is active)
    var portalEntryY: CGFloat? = nil
    var portalExitY:  CGFloat? = nil
    
    // MARK: - ECS
    var entityManager:   EntityManager!
    var movementSystem:  MovementSystem!
    var collisionSystem: CollisionSystem!
    var healthSystem:    HealthSystem!
    var controllerSystem: ControllerSystem!
    
    // MARK: - State Machine
    var stateMachine: GKStateMachine!
    
    // MARK: - Player entity (shooter marker)
    var playerEntity: PlayerEntity?
    
    // MARK: - HUD Nodes
    var countLabel: SKLabelNode!
    var ammoContainer = SKNode()
    var portalLabel: SKLabelNode!
    var turnLabel:   SKLabelNode!
    var nextMarker:  SKShapeNode?
    var aimDots: [SKShapeNode] = []
    var aimArrow: SKShapeNode?
    var landedBallNodes: [SKSpriteNode] = []
    var isVolleyActive = false
    
    // MARK: - AssetNode
    var bakpaoNode:  SKSpriteNode?
    var pandaNode: SKSpriteNode?
    var bgCheckeredNode:  SKSpriteNode?
    var backgroundNode: SKSpriteNode?
    var greenBlockNode: SKSpriteNode?
    var yellowBlockNode: SKSpriteNode?
    var pinkBlockNode: SKSpriteNode?
    var collectBakpaoNode: SKSpriteNode?
    var bgBrownNode: SKSpriteNode?
    var gameFrameNode: SKSpriteNode?
    var pandaFrames: [SKTexture] = []
    
    
    // MARK: - didMove
    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        entityManager    = EntityManager(scene: self)
        movementSystem   = MovementSystem()
        collisionSystem  = CollisionSystem()
        healthSystem     = HealthSystem()
        controllerSystem = ControllerSystem(scene: self)
        
        // State machine: Aiming → Flying → TurnEnd → Aiming
        stateMachine = GKStateMachine(states: [
            GameAimingState(),
            GameFlyingState(),
            GameTurnEndState()
        ])
        stateMachine.enter(GameAimingState.self)
        
        physicsWorld.gravity         = .zero
        physicsWorld.contactDelegate = self
        
        computeLayout(in: view)
        setupAssets()
        
        buildBackground()
        loadOverlayFromSKS()
        buildWalls()
        buildHUD()
        placeShooterMarker()
        spawnInitialRows()
        addPanGesture(to: view)
        
        
        for family in UIFont.familyNames.sorted() {
            
            print("FAMILY:", family)
            
            for name in UIFont.fontNames(forFamilyName: family) {
                
                print(" FONT:", name)
            }
        }
    }
    
    
    
    
    
    // MARK: - Block / Pickup Spawning
    
    func spawnInitialRows() {
        for r in 0...2 { spawnRow(r) }
    }
    
    func spawnRow(_ row: Int) {
        guard row < GameConstants.blockRows else { return }
        
        let shuffled  = Array(0..<GameConstants.cols).shuffled()
        let nBlocks   = Int.random(in: 2...4)
        let blockCols = Set(shuffled.prefix(nBlocks))
        var emptyCols = shuffled.filter { !blockCols.contains($0) }.shuffled()
        
        // Ammo pickup: probability decreases with turns (min 20%)
        let ammoChance = max(20, 45 - turnNumber * 2)
        var ammoCol:   Int? = Int.random(in: 0...99) < ammoChance ? emptyCols.first : nil
        if ammoCol   != nil { emptyCols.removeFirst() }
        
        // Portal token: rare, only available from turn 6
        let portalChance = turnNumber >= 6 ? 12 : 0
        var portalCol: Int? = (!emptyCols.isEmpty && Int.random(in: 0...99) < portalChance)
        ? emptyCols.first : nil
        if portalCol != nil && !emptyCols.isEmpty { emptyCols.removeFirst() }
        
        for c in 0..<GameConstants.cols {
            let pos = cellCenter(col: c, row: row)
            if blockCols.contains(c) {
                let hp   = RandomManager.shared.blockHP(ballCount: ballCount)
                //                let type = RandomManager.shared.randomBlockType(turnNumber: turnNumber)
                let type: BlockType = .normal
                addBlockEntity(at: pos, type: type, hp: hp)
            } else if c == ammoCol {
                addPickupEntity(at: pos, type: .ammo)
            } else if c == portalCol {
                addPickupEntity(at: pos, type: .portalToken)
            }
        }
    }
    
    //MARK: Collision
}
