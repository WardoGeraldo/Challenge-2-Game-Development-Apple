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
final class GameScene: SKScene {
    
    // MARK: - Layout (computed dynamically from screen size)
    var cell:       CGFloat = 44
    let gap: CGFloat = 0
    var step: CGFloat { cell }
    var gridOrigin: CGPoint = .zero
    var gridW:      CGFloat = 0
    var gridH:      CGFloat = 0
    var shootY:     CGFloat = 0
    var shootX:     CGFloat = 0
    var gridScale: CGFloat = 0.9
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
    
    var onGameOver: (() -> Void)?
    var onPause: (() -> Void)?
    var isGameOver = false
    
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
    var scoreLabel:   SKLabelNode!
    var countLabel:   SKLabelNode!
    var ammoCountLabel: SKLabelNode!
    var ammoContainer = SKNode()
    var turnLabel:    SKLabelNode!
    var nextMarker:  SKShapeNode?
    var aimDots: [SKShapeNode] = []
    var aimArrow: SKShapeNode?
    var landedBallNodes: [SKNode] = []
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
    var bakpaoCountFrameNode: SKSpriteNode?
    var pauseFrameNode: SKSpriteNode?
    var pauseButtonNode: SKSpriteNode?
    
    
    // MARK: - Entry Point
    override func willMove(from view: SKView) {
        view.gestureRecognizers?.forEach { view.removeGestureRecognizer($0) }
    }

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        //Ambience Background in Game
        SoundManager.shared.playBGM(track: .relaxAmbience, volume: 1.0)
        entityManager    = EntityManager(scene: self)
        movementSystem   = MovementSystem()
        collisionSystem  = CollisionSystem()
        healthSystem     = HealthSystem()
        controllerSystem = ControllerSystem()
        
        // State machine: Aiming → Flying → TurnEnd → Aiming
        stateMachine = GKStateMachine(states: [
            GameStartState(entityManager),
            GameIdleState(entityManager),
            GameAimState(entityManager),
            GameFlyingState(entityManager),
            GameTurnEndState(entityManager),
            GameOverState(entityManager),
        ])
        stateMachine.enter(GameAimState.self)
        
        physicsWorld.gravity         = .zero
        physicsWorld.contactDelegate = self
        
        ScoreManager.shared.reset()
        computeLayout(in: view)
        setupAssets()
        
        buildBackground()
        loadOverlayFromSKS()
        buildWalls()
        buildHUD()
        placeShooterMarker()
        spawnInitialRows()
        addPanGesture(to: view)
        addTapGesture(to: view)
        
        
//        for family in UIFont.familyNames.sorted() {
//            
//            print("FAMILY:", family)
//            
//            for name in UIFont.fontNames(forFamilyName: family) {
//                
//                print(" FONT:", name)
//            }
//        }
    }
    
    // MARK: - Spawning

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
        
        for c in 0..<GameConstants.cols {
            let pos = cellCenter(col: c, row: row)
            if blockCols.contains(c) {
                let type = RandomManager.shared.generateBlockType()
                let hp   = RandomManager.shared.generateFairHP(currentAmmo: ballCount, type: type)
                //                let type = RandomManager.shared.randomBlockType(turnNumber: turnNumber)
                addBlockEntity(at: pos, type: type, hp: hp)
            } else if c == ammoCol {
                addPickupEntity(at: pos, type: .ammo)
            }
        }
    }
    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        let dt: CGFloat = lastDT == 0
        ? 1 / 60.0
        : CGFloat(min(currentTime - lastDT, 1 / 30.0))
        lastDT = currentTime
        
        // Rover movement always runs (even during aiming)
        movementSystem.update(
            deltaTime: dt,
            entityManager: entityManager,
            cell: cell,
            gap: gap,
            gridOriginX: gridOrigin.x,
            gridWidth: gridW
        )
        
        // Drain collision events queued by didBegin and call the right handler
        for event in collisionSystem.dequeueAll() {
            if event.isBlock {
                handleBlockHit(node: event.otherNode)
                ScoreManager.shared.addPoints(10)
            } else {
                handlePickupCollected(node: event.otherNode)
            }
        }
        
        guard stateMachine.currentState is GameFlyingState else { return }
        
        // Ball position updates
        for entity in entityManager.entities(with: VelocityComponent.self) {
            guard let velComp = entity.component(ofType: VelocityComponent.self),
                  let render  = entity.component(ofType: RenderComponent.self),
                  let body    = render.node.physicsBody,
                  body.isDynamic else { continue }
            let sprite = render.node
            let v = body.velocity

            // Land when ball returns to shooter row with non-upward velocity.
            // No hasRisen check needed: balls are always fired upward (angle clamped
            // to ≥8°), so dy > 0 at shootY on departure — this only fires on return.
            if sprite.position.y <= shootY && v.dy <= 0 {
                ballLanded(entity: entity, ball: sprite)
                continue
            }
            
            // Gravity only fires when the ball is moving downward or within ~3° of
            // horizontal. Upward-moving balls (vy > threshold) travel in a straight
            // line so low-angle shots feel natural. Stuck horizontal balls accumulate
            // the downward nudge over a few seconds and land on their own.
            let vx  = v.dx
            let rawVY = v.dy
            let vy  = rawVY < GameConstants.ballSpeed * 0.05
            ? rawVY - GameConstants.gravityAccel * dt
            : rawVY
            let spd = hypot(vx, vy)
            if spd > 1 {
                body.velocity = CGVector(
                    dx: vx / spd * GameConstants.ballSpeed,
                    dy: vy / spd * GameConstants.ballSpeed
                )
                sprite.position.x = min(max(sprite.position.x, gridOrigin.x), gridOrigin.x + gridW)
                sprite.position.y = min(max(sprite.position.y, gridOrigin.y), gridOrigin.y + gridH)
            }
        }
    }
}
