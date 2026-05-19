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
        let block = BlockEntity(health: 5)
        entityManager.add(block)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime

        entityManager.update(deltaTime)
    func cellCenter(col: Int, row: Int) -> CGPoint {

        return CGPoint(
            x:
                gridOrigin.x
                + CGFloat(col) * cell
                + cell / 2,

            y:
                gridOrigin.y
                + gridH
                - CGFloat(row) * cell
                - cell / 2
        )
    }

    // MARK: - Background
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

    // MARK: - Walls (left, right, top — no floor so balls can land)
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
    
    // MARK: - HUD
    func buildHUD() {
        ammoContainer.zPosition = 10
        ammoContainer.name = "ui"
        addChild(ammoContainer)

        ammoContainer.position = CGPoint(
            x: shootX - 24,
            y: shootY
        )

        // Label jumlah bakpao
        countLabel = SKLabelNode(fontNamed: GameConstants.fontName)
        countLabel.fontSize = 18
        countLabel.fontColor = UIColor.white
        countLabel.horizontalAlignmentMode = .left
        countLabel.verticalAlignmentMode = .center
        countLabel.zPosition = 11
        addChild(countLabel)

        // Portal label
        portalLabel = SKLabelNode(fontNamed: GameConstants.fontName)
        portalLabel.fontSize = 14
        portalLabel.fontColor = UIColor(
            red: 0.72,
            green: 0.50,
            blue: 1.0,
            alpha: 1
        )

        portalLabel.horizontalAlignmentMode = .left
        portalLabel.verticalAlignmentMode = .center
        portalLabel.position = CGPoint(
            x: gridOrigin.x + 160,
            y: shootY
        )

        portalLabel.zPosition = 10
        addChild(portalLabel)

        // Turn label
        turnLabel = SKLabelNode(fontNamed: GameConstants.fontName)
        turnLabel.fontSize = 13
        turnLabel.fontColor = UIColor(white: 0.5, alpha: 1)

        turnLabel.horizontalAlignmentMode = .right
        turnLabel.verticalAlignmentMode = .center

        turnLabel.position = CGPoint(
            x: gridOrigin.x + gridW - 6,
            y: shootY
        )

        turnLabel.zPosition = 10
        addChild(turnLabel)

        refreshHUD()
    }

    
    func refreshHUD() {
        updateAmmoIcons()
        ammoContainer.run(.sequence([
            .scale(to: 1.12, duration: 0.06),
            .scale(to: 1.0, duration: 0.08)
        ]))
    }
    

    func updateAmmoIcons() {
        ammoContainer.removeAllChildren()

        // Kalau lagi volley → jangan tampilkan ammo bawah
        if isVolleyActive {
            countLabel.text = ""
            return
        }

        let size: CGFloat = GameConstants.ballRadius * 1.75
        let maxWidth: CGFloat = 120
        let spacing: CGFloat
       
        if ballCount <= 5 {
            spacing = size * 0.72
        } else if ballCount <= 10 {
            spacing = size * 0.48
        } else {
            spacing = size * 0.28
        }

        let totalWidth = CGFloat(max(ballCount - 1, 0)) * spacing
        let clampedWidth = min(totalWidth, maxWidth)
        let finalSpacing: CGFloat

        if ballCount > 1 {
            finalSpacing = min(
                spacing,
                clampedWidth / CGFloat(ballCount - 1)
            )
        } else {
            finalSpacing = spacing
        }

        let startX = CGFloat(0)

        for i in 0..<ballCount {

            guard let sprite = bakpaoNode?.copy() as? SKSpriteNode else {
                continue
            }

            sprite.size = CGSize(width: size, height: size)

            sprite.position = CGPoint(
                x: startX + CGFloat(i) * finalSpacing,
                y: CGFloat.random(in: -2...2)
            )

            sprite.zRotation = CGFloat.random(in: -0.18...0.18)

            sprite.zPosition = CGFloat(i)

            let scale = CGFloat.random(in: 0.94...1.04)
            sprite.setScale(scale)

            ammoContainer.addChild(sprite)

            let delay = Double(i) * 0.05

            let moveUp = SKAction.moveBy(
                x: 0,
                y: CGFloat.random(in: 2...5),
                duration: Double.random(in: 0.6...1.0)
            )

            moveUp.timingMode = .easeInEaseOut

            let moveDown = moveUp.reversed()

            let floatAnim = SKAction.sequence([
                .wait(forDuration: delay),
                .sequence([moveUp, moveDown])
            ])

            sprite.run(.repeatForever(floatAnim))
        }

        countLabel.text = ""
    }
    
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
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard
            let nodeA = contact.bodyA.node,
            let nodeB = contact.bodyB.node,
            let entityA = entityManager.entity(forNode: nodeA),
            let entityB = entityManager.entity(forNode: nodeB)
        else { return }

        guard
            let physicsComponentA = entityA.component(
                ofType: PhysicsComponent.self
            )
        else {
            return
    func addBlockEntity(at pos: CGPoint, type: BlockType, hp: Int) {
        let node = BlockNode.make(type: type, hp: hp, ballCount: ballCount, cell: cell)
        node.position = pos

        // Detach physics during the 0.35s spawn animation — prevents the ball
        // from bouncing off a block that's still at 20% scale (invisible).
        let spawnBody    = node.physicsBody
        node.physicsBody = nil

        let entity = BlockEntity(node: node, hp: hp, type: type)
        entityManager.add(entity)

        // Re-attach physics after spawn animation completes
        node.run(.sequence([
            .wait(forDuration: 0.36),
            .run { [weak node] in
                guard let node, node.parent != nil else { return }
                node.physicsBody = spawnBody
            }
        ]))
    }

    func addPickupEntity(at pos: CGPoint, type: PickupType) {
        let node: SKNode
        switch type {
        case .ammo:
            let n = AmmoPickupNode(cell: cell)
            n.position = pos
            node = n
        case .portalToken:
            let n = PortalPickupNode(cell: cell)
            n.position = pos
            node = n
        }
        let entity = ItemBallEntity(node: node, type: type)
        entityManager.add(entity)
    }

        physicsComponentA.contactQueue.append(
            PhysicsContact(
                entityA: entityA,
                entityB: entityB,
            )
        )
    // MARK: - Gesture (Aiming)

    func addPanGesture(to view: SKView) {
        view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        )
    }
    
    func updateAimDots(angle: CGFloat) {
        guard let gridNode = bgCheckeredNode else { return }

        let gridFrame = gridNode.frame
        removeAimDots()
        
        let start = CGPoint(
            x: min(max(shootX, playAreaRect.minX), playAreaRect.maxX),
            y: min(max(shootY, playAreaRect.minY), playAreaRect.maxY)
        )
        
        let direction = CGVector(
            dx: cos(angle),
            dy: sin(angle)
        )
        
        // Maximum ray length
        let maxDistance: CGFloat = max(gridW, gridH)

        let end = CGPoint(
            x: start.x + direction.dx * maxDistance,
            y: start.y + direction.dy * maxDistance
        )
        
        // Default target
        var targetPoint = end

        let minX = gridFrame.minX
        let maxX = gridFrame.maxX
        let minY = gridFrame.minY
        let maxY = gridFrame.maxY

        targetPoint.x = min(max(targetPoint.x, playAreaRect.minX), playAreaRect.maxX)
        targetPoint.y = min(max(targetPoint.y, playAreaRect.minY), playAreaRect.maxY)
        
        // ===== Raycast =====
        
        physicsWorld.enumerateBodies(
            alongRayStart: start,
            end: end
        ) { body, point, normal, stop in
            
            guard let node = body.node else { return }
            
            // Ignore balls/player/pickups/ui
            if node.name == "ball"
                || node.name == "player"
                || node.name == "pickup_ammo"
                || node.name == "pickup_portal"
                || node.name == "ui" {
                
                return
            }
            
            // Only stop on wall/block
            let category = body.categoryBitMask
            
            let validHit =
            category == PhysicsCategory.wall
            || category == PhysicsCategory.block
            
            if validHit {
                
                targetPoint = point
                
                stop.pointee = true
            }
            targetPoint.x = min(max(targetPoint.x, minX), maxX)
            targetPoint.y = min(max(targetPoint.y, minY), maxY)
        }
        
        // ===== Distance =====
        
        let totalDistance = hypot(
            targetPoint.x - start.x,
            targetPoint.y - start.y
        )
        
        let spacing: CGFloat = 24
        
        let count = max(1, Int(totalDistance / spacing))
        
        let arrowSize: CGFloat = 18
        
        let dotCount = max(
            1,
            Int(totalDistance / spacing)
        )
        
        // ===== DOTS =====
        // Hanya sampai sebelum terakhir
        for i in 0..<(dotCount - 1) {
            
            let progress = CGFloat(i) / CGFloat(max(dotCount - 1, 1))
            
            let pos = CGPoint(
                x: start.x + (targetPoint.x - start.x) * progress,
                y: start.y + (targetPoint.y - start.y) * progress
            )
            
            let size = max(
                4,
                10 - CGFloat(i) * 0.15
            )
            
            let dot = SKShapeNode(
                circleOfRadius: size
            )
            
            dot.fillColor = UIColor.white.withAlphaComponent(
                max(0.25, 0.92 - CGFloat(i) * 0.03)
            )
            
            dot.strokeColor = .clear
            
            dot.position = pos
            
            dot.zPosition = 20
            
            addChild(dot)
            
            aimDots.append(dot)
        }
        
        //
        // ===== ROUNDED ARROW =====
        // Posisi menggantikan dot terakhir
        //
        
        let arrowProgress = CGFloat(dotCount - 1) / CGFloat(max(dotCount - 1, 1))
        
        let arrowOffset = arrowSize * 0.9

        let arrowPos = CGPoint(
            x: start.x + (targetPoint.x - start.x) * arrowProgress,
            y: start.y + (targetPoint.y - start.y) * arrowProgress
        )
        
        let arrow = SKShapeNode()
        
        let arrowAngle = atan2(
            direction.dy,
            direction.dx
        )
        
        // Rounded triangle points
        let tip = CGPoint(
            x: cos(arrowAngle) * arrowSize,
            y: sin(arrowAngle) * arrowSize
        )
        
        let left = CGPoint(
            x: cos(arrowAngle + .pi * 0.82) * arrowSize * 0.72,
            y: sin(arrowAngle + .pi * 0.82) * arrowSize * 0.72
        )
        
        let right = CGPoint(
            x: cos(arrowAngle - .pi * 0.82) * arrowSize * 0.72,
            y: sin(arrowAngle - .pi * 0.82) * arrowSize * 0.72
        )
        
        // Smooth rounded path
        let path = UIBezierPath()
        
        path.move(to: tip)
        
        path.addQuadCurve(
            to: left,
            controlPoint: CGPoint(
                x: (tip.x + left.x) / 2,
                y: (tip.y + left.y) / 2
            )
        )
        
        path.addQuadCurve(
            to: right,
            controlPoint: CGPoint(
                x: 0,
                y: 0
            )
        )
        
        path.addQuadCurve(
            to: tip,
            controlPoint: CGPoint(
                x: (tip.x + right.x) / 2,
                y: (tip.y + right.y) / 2
            )
        )
        
        path.close()
        
        arrow.path = path.cgPath
        
        arrow.fillColor = UIColor.white.withAlphaComponent(0.96)
        
        arrow.strokeColor = .clear
        
        arrow.position = clampToPlayArea(arrowPos)
        
        arrow.zPosition = 21
        
        addChild(arrow)
        
        aimArrow = arrow
    }
    
    @objc func onPan(_ g: UIPanGestureRecognizer) {

        guard stateMachine.currentState is GameAimingState else { return }

        let raw = g.translation(in: view)

        let angle = clampAngle(
            dx: raw.x,
            dy: -raw.y
        )

        switch g.state {

        case .began, .changed:

            updateAimDots(angle: angle)

            // Simpan angle ke player component
            playerEntity?
                .component(ofType: ControlComponent.self)?
                .shotAngle = angle

        case .ended, .cancelled:

            removeAimDots()

            shotAngle = angle

            startVolley(angle: angle)

        default:
            break
        }
    }
    func removeAimDots() {

        aimArrow?.removeFromParent()
        aimArrow = nil

        for dot in aimDots {
            dot.removeFromParent()
        }

        aimDots.removeAll()
    }

    // Clamps angle to at least 8° from horizontal so balls always move upward
    func clampAngle(dx: CGFloat, dy: CGFloat) -> CGFloat {
        let min8 = CGFloat(8) * .pi / 180
        var a    = atan2(dy, dx)
        if dy <= 0 { a = dx >= 0 ? min8 : .pi - min8 }
        else       { a = Swift.min(Swift.max(a, min8), .pi - min8) }
        return a
    }

    // MARK: - Volley

    func startVolley(angle: CGFloat) {
        isVolleyActive = true
        refreshHUD()
        shotAngle    = angle
        volleyTotal  = ballCount
        volleyLanded = 0
//        firstLandX   = nil
        landedPositions.removeAll()
        landedBallNodes.removeAll()

        stateMachine.enter(GameFlyingState.self)

        // Activate portal warp if a charge is available
        if portalCharges > 0 {
            portalCharges -= 1
            refreshHUD()
            activatePortalVolley()
        }

        // Fire all balls with staggered delay
        for i in 0..<volleyTotal {
            run(.sequence([
                .wait(forDuration: TimeInterval(i) * GameConstants.shootGap),
                .run { [weak self] in self?.fireOneBall() }
            ]))
        }
    }

    func fireOneBall() {
//        let node = BallNode(radius: GameConstants.ballRadius)
        guard let texture = bakpaoNode?.texture else { return }

        let node = BallNode(
            texture: texture,
            radius: GameConstants.ballRadius
        )
        node.position = CGPoint(x: shootX, y: shootY)
        let entity    = BallEntity(node: node)
        entityManager.add(entity)

        // Apply velocity
        node.physicsBody?.velocity = CGVector(
            dx: cos(shotAngle) * GameConstants.ballSpeed,
            dy: sin(shotAngle) * GameConstants.ballSpeed
        )
    }

    // MARK: - Portal Volley

    // Places entry (top half) and exit (bottom half) warp rings.
    // Balls passing through the entry ring are teleported to the exit band in update().
    func activatePortalVolley() {
        var occupied = Set<String>()
        entityManager.entities(with: BlockTypeComponent.self).forEach {
            guard let render = $0.component(ofType: RenderComponent.self) else { return }
            let col = Int(round((render.node.position.x - gridOrigin.x - gap - cell/2) / step))
            let row = Int(round((gridOrigin.y + gridH - gap - cell/2 - render.node.position.y) / step))
            occupied.insert("\(col),\(row)")
        }
        entityManager.entities(with: ConsumableComponent.self).forEach {
            guard let render = $0.component(ofType: RenderComponent.self) else { return }
            let col = Int(round((render.node.position.x - gridOrigin.x - gap - cell/2) / step))
            let row = Int(round((gridOrigin.y + gridH - gap - cell/2 - render.node.position.y) / step))
            occupied.insert("\(col),\(row)")
        }

        func emptyCell(inRows range: ClosedRange<Int>) -> CGPoint? {
            var candidates: [CGPoint] = []
            for row in range {
                for col in 0..<GameConstants.cols {
                    if !occupied.contains("\(col),\(row)") {
                        candidates.append(cellCenter(col: col, row: row))
                    }
                }
            }
            return candidates.randomElement()
        }

        guard let topPos    = emptyCell(inRows: 0...3),
              let bottomPos = emptyCell(inRows: 4...7) else { return }

        portalEntryY = topPos.y
        portalExitY  = bottomPos.y

        let pairs: [(CGPoint, UIColor)] = [
            (topPos,    UIColor(red: 0.72, green: 0.50, blue: 1.0, alpha: 0.9)),
            (bottomPos, UIColor(red: 0.50, green: 0.85, blue: 0.72, alpha: 0.9))
        ]

        for (pos, color) in pairs {
            let ring = SKShapeNode(circleOfRadius: cell * 0.40)
            ring.fillColor   = color.withAlphaComponent(0.13)
            ring.strokeColor = color
            ring.lineWidth   = 2.5
            ring.position    = pos
            ring.zPosition   = 8
            ring.name        = "portalRing"

            let inner = SKShapeNode(circleOfRadius: cell * 0.22)
            inner.fillColor   = .clear
            inner.strokeColor = color.withAlphaComponent(0.55)
            inner.lineWidth   = 1.2
            inner.run(.repeatForever(.rotate(byAngle: -.pi * 2, duration: 1.2)))
            ring.addChild(inner)
            ring.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 2.0)))
            addChild(ring)
        }

        // Safety cleanup after 12s in case volley runs long
        run(.sequence([
            .wait(forDuration: 12),
            .run { [weak self] in self?.clearPortalRings() }
        ]))
    }

    func clearPortalRings() {
        enumerateChildNodes(withName: "portalRing") { n, _ in n.removeFromParent() }
        portalEntryY = nil
        portalExitY  = nil
    }

    // MARK: - update

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

        // Process queued collision events
        for event in collisionSystem.dequeueAll() {
            if event.isBlock {
                handleBlockHit(node: event.otherNode)
            } else {
                handlePickupCollected(node: event.otherNode)
            }
        }

        guard stateMachine.currentState is GameFlyingState else { return }

        // Ball position updates
        for entity in entityManager.entities(with: VelocityComponent.self) {
            guard let velComp = entity.component(ofType: VelocityComponent.self),
                  let render  = entity.component(ofType: RenderComponent.self),
                  let sprite  = render.node as? SKSpriteNode,
                  let body    = sprite.physicsBody,
                  body.isDynamic else { continue }

            // Accumulate flight time and force-land any ball stuck for too long.
            // This is the hard backstop against infinite horizontal bounce loops.
            velComp.flightTime += dt
            if velComp.flightTime > 10 {
                ballLanded(entity: entity, ball: sprite)
                continue
            }

            let v = body.velocity

            // Track rise above shooter row
            if sprite.position.y > shootY + cell {
                velComp.hasRisen = true
            }

            // Detect landing: ball rose and returned to/below the shooter row moving down
            if velComp.hasRisen && sprite.position.y <= shootY && v.dy <= 0 {
                ballLanded(entity: entity, ball: sprite)
                continue
            }

            // Portal warp: teleport ball at entry band to exit band
            if let entryY = portalEntryY, let exitY = portalExitY {
                if abs(sprite.position.y - entryY) < cell * 0.4 && v.dy > 0 {
                    sprite.position.y = exitY
                    sprite.run(.sequence([
                        .scale(to: 1.5, duration: 0.05),
                        .scale(to: 1.0, duration: 0.08)
                    ]))
                }
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

    // MARK: - Physics Contacts

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask
        let pair = a | b

        // Ball ↔ Block
        if pair == PhysicsCategory.ball | PhysicsCategory.block {
            guard let ballNode  = (a == PhysicsCategory.ball  ? contact.bodyA : contact.bodyB).node,
                  let blockNode = (a == PhysicsCategory.block ? contact.bodyA : contact.bodyB).node
            else { return }
            collisionSystem.enqueue(CollisionEvent(ballNode: ballNode, otherNode: blockNode, isBlock: true))
        }

        // Ball ↔ Pickup
        if pair == PhysicsCategory.ball | PhysicsCategory.pickup {
            guard let ballNode   = (a == PhysicsCategory.ball   ? contact.bodyA : contact.bodyB).node,
                  let pickupNode = (a == PhysicsCategory.pickup ? contact.bodyA : contact.bodyB).node
            else { return }
            collisionSystem.enqueue(CollisionEvent(ballNode: ballNode, otherNode: pickupNode, isBlock: false))
        }
    }

    // MARK: - Block Hit Handling

    func handleBlockHit(node: SKNode) {
        guard let entity = entityManager.entity(forNode: node) else { return }
        animateBlockHit(node)

        let dead = healthSystem.hit(entity: entity, ballCount: ballCount)

        if dead {
            let isBomb = entity.component(ofType: BlockTypeComponent.self)?.blockType.isBomb ?? false

            // Deregister from ECS first so no further hits are processed for this node.
            // physicsBody is already nil'd by HealthSystem — do NOT call entityManager.remove()
            // here because that would call node.removeFromParent() and cancel the death animation.
            entityManager.untrack(entity)

            if isBomb {
                explode(at: node.position)
                HapticManager.shared.play(.heavy)
            } else {
                HapticManager.shared.play(.rigid)
            }

            movementSystem.unstickRovers(near: node.position,
                                         entityManager: entityManager,
                                         cell: cell)
            // Animation handles its own removeFromParent() at the end
            animateBlockDeath(node: node, isBomb: isBomb)
        } else {
            let hp    = entity.component(ofType: HealthComponent.self)?.health ?? 1
            let ratio = CGFloat(hp) / CGFloat(max(ballCount, 1))
            if ratio < 0.5 {
                HapticManager.shared.play(.medium)
            } else {
                HapticManager.shared.play(.light)
            }
        }
    }
    
    func animateBlockHit(_ node: SKNode) {

        guard let sprite =
            node.childNode(withName: "blockSprite")
                as? SKSpriteNode
        else { return }

        sprite.removeAction(forKey: "hitAnim")

        let hit = SKAction.sequence([

            .group([

                .scaleX(to: 0.88, duration: 0.045),
                .scaleY(to: 1.08, duration: 0.045)

            ]),

            .group([

                .scaleX(to: 1.0, duration: 0.08),
                .scaleY(to: 1.0, duration: 0.08)

            ])
        ])

        hit.timingMode = .easeOut

        sprite.run(
            hit,
            withKey: "hitAnim"
        )

        let shake = SKAction.sequence([

            .moveBy(x: -2, y: 0, duration: 0.02),
            .moveBy(x:  4, y: 0, duration: 0.04),
            .moveBy(x: -2, y: 0, duration: 0.02)
        ])

        node.run(shake)
    }

    func animateBlockDeath(node: SKNode, isBomb: Bool) {
        let scale: CGFloat = isBomb ? 1.5 : 1.2
        node.run(.sequence([
            .group([
                .scale(to: scale, duration: 0.07),
                .fadeOut(withDuration: 0.09)
            ]),
            .removeFromParent()
        ]))
    }

    // MARK: - Bomb Explosion

    func explode(at pos: CGPoint) {
        // Expanding blast ring
        let ring = SKShapeNode(circleOfRadius: 4)
        ring.fillColor   = .clear
        ring.strokeColor = UIColor(red: 1.0, green: 0.55, blue: 0.2, alpha: 0.9)
        ring.lineWidth   = 3
        ring.position    = pos
        ring.zPosition   = 8
        addChild(ring)
        ring.run(.sequence([
            .group([
                .scale(to: (cell * 2.8) / 4, duration: 0.35),
                .sequence([.wait(forDuration: 0.15), .fadeOut(withDuration: 0.20)])
            ]),
            .removeFromParent()
        ]))

        // Sparks
        for _ in 0..<10 {
            let spark = SKShapeNode(circleOfRadius: 3)
            spark.fillColor   = UIColor(red: 1.0, green: CGFloat.random(in: 0.4...0.9),
                                        blue: 0.1, alpha: 1)
            spark.strokeColor = .clear
            spark.position    = pos
            spark.zPosition   = 8
            addChild(spark)
            let dx = CGFloat.random(in: -60...60)
            let dy = CGFloat.random(in: -60...60)
            spark.run(.sequence([
                .group([.moveBy(x: dx, y: dy, duration: 0.4), .fadeOut(withDuration: 0.4)]),
                .removeFromParent()
            ]))
        }

        // Hit adjacent blocks in blast radius
        let blastR = cell * 1.6
        for entity in entityManager.entities(with: BlockTypeComponent.self) {
            guard let render = entity.component(ofType: RenderComponent.self) else { continue }
            let dist = hypot(render.node.position.x - pos.x, render.node.position.y - pos.y)
            if dist < blastR && dist > 1 {
                handleBlockHit(node: render.node)
            }
        }
    }

    // MARK: - Pickup Collection

    func handlePickupCollected(node: SKNode) {
        guard let entity = entityManager.entity(forNode: node) else { return }
        guard let consumable = entity.component(ofType: ConsumableComponent.self) else { return }

        // Deregister and remove physics so the same pickup can't be collected twice
        entityManager.untrack(entity)
        node.physicsBody = nil
        node.removeFromParent()

        switch consumable.pickupType {
        case .ammo:
            let previousCount = ballCount
            ballCount += 1

            HapticManager.shared.play(.medium)

            animateAmmoGain(
                from: node.position,
                oldCount: previousCount,
                newCount: ballCount
            )

            refreshHUD()

            floatLabel(
                "+1",
                at: node.position,
                color: UIColor(
                    red: 0.45,
                    green: 0.72,
                    blue: 1.0,
                    alpha: 1
                )
            )
        case .portalToken:
            portalCharges += 1
            refreshHUD()
            HapticManager.shared.play(.heavy)
            floatLabel("⬡ portal!", at: node.position, color: UIColor(red: 0.72, green: 0.50, blue: 1.0, alpha: 1))
        
        }
    }

    func floatLabel(_ text: String, at pos: CGPoint, color: UIColor) {
        let lbl = SKLabelNode(fontNamed: GameConstants.fontName)
        lbl.text      = text
        lbl.fontSize  = 18
        lbl.fontColor = color
        lbl.position  = pos
        lbl.zPosition = 12
        addChild(lbl)
        lbl.run(.sequence([
            .group([
                .moveBy(x: 0, y: 34, duration: 0.55),
                .sequence([.wait(forDuration: 0.25), .fadeOut(withDuration: 0.30)])
            ]),
            .removeFromParent()
        ]))
    }

    // MARK: - Ball Landing
    func ballLanded(entity: GKEntity, ball: SKSpriteNode) {

        // Clamp posisi landing
        let lo = gridOrigin.x + GameConstants.ballRadius + gap
        let hi = gridOrigin.x + gridW - GameConstants.ballRadius - gap

        let clampedX = Swift.min(
            Swift.max(ball.position.x, lo),
            hi
        )

        landedPositions.append(clampedX)

        // Stop physics
        ball.physicsBody?.velocity = .zero
        ball.physicsBody = nil

        entityManager.untrack(entity)

        // Snap ke floor
        ball.position = CGPoint(
            x: clampedX,
            y: shootY
        )

        // Simpan node
        landedBallNodes.append(ball)

        // Idle floating kecil
        let float = SKAction.sequence([
            .moveBy(x: 0, y: 2, duration: 0.45),
            .moveBy(x: 0, y: -2, duration: 0.45)
        ])

        ball.run(
            .repeatForever(float),
            withKey: "idleFloat"
        )

        volleyLanded += 1

        showNextMarker(x: clampedX)

        if volleyLanded >= volleyTotal {
            endVolley()
        }
    }
    
    func showNextMarker(x: CGFloat) {

        nextMarker?.removeFromParent()

        let dot = SKShapeNode(
            circleOfRadius: GameConstants.ballRadius * 0.7
        )

        dot.fillColor = UIColor(
            red: 0.45,
            green: 0.72,
            blue: 1.0,
            alpha: 0.25
        )

        dot.strokeColor = UIColor(
            red: 0.45,
            green: 0.72,
            blue: 1.0,
            alpha: 0.65
        )

        dot.lineWidth = 1.5

        dot.position = CGPoint(
            x: x,
            y: shootY
        )

        dot.zPosition = 4
        dot.name = "ui"

        addChild(dot)

        nextMarker = dot
    }
    
    func calculateBestLandingX() -> CGFloat {

        guard !landedPositions.isEmpty else {
            return frame.midX
        }

        let bucketSize: CGFloat = 40

        var buckets: [Int: [CGFloat]] = [:]

        for x in landedPositions {

            let key = Int(x / bucketSize)

            buckets[key, default: []].append(x)
        }

        // Bucket terbanyak
        let best = buckets.max {
            $0.value.count < $1.value.count
        }

        guard let values = best?.value else {
            return frame.midX
        }

        // Average position
        let avg = values.reduce(0, +) / CGFloat(values.count)

        // Clamp screen
        let lo = gridOrigin.x + 30
        let hi = gridOrigin.x + gridW - 30

        return min(max(avg, lo), hi)
    }
    
    
    func repositionLandedBallsAroundPlayer() {

        guard !landedBallNodes.isEmpty else { return }

        // Dynamic spacing
        let spacing: CGFloat

        if landedBallNodes.count <= 5 {
            spacing = 16
        } else if landedBallNodes.count <= 12 {
            spacing = 12
        } else {
            spacing = 8
        }

        // Total width
        let totalWidth =
            CGFloat(landedBallNodes.count - 1) * spacing

        // Clamp supaya ga keluar layar
        let minX = gridOrigin.x + 20
        let maxX = gridOrigin.x + gridW - totalWidth - 20

        let startX = min(
            max(shootX - totalWidth / 2, minX),
            maxX
        )

        for (index, ball) in landedBallNodes.enumerated() {

            ball.removeAction(forKey: "idleFloat")

            let target = CGPoint(
                x: startX + CGFloat(index) * spacing,
                y: shootY
            )

            let move = SKAction.move(
                to: target,
                duration: 0.32
            )

            move.timingMode = .easeInEaseOut

            let bounce = SKAction.sequence([
                .moveBy(x: 0, y: 4, duration: 0.08),
                .moveBy(x: 0, y: -4, duration: 0.10)
            ])

            let rotate = SKAction.rotate(
                toAngle: CGFloat.random(in: -0.15...0.15),
                duration: 0.2
            )

            ball.run(.group([
                .sequence([move, bounce]),
                rotate
            ]))
        }
    }

    // MARK: - End Volley / Advance Board
    func endVolley() {

        // Cari posisi landing paling ramai
        shootX = calculateBestLandingX()
        updateAmmoContainerPosition()

        stateMachine.enter(GameTurnEndState.self)

        clearPortalRings()

        nextMarker?.removeFromParent()
        nextMarker = nil

        // Kumpulkan bakpao ke player baru
        repositionLandedBallsAroundPlayer()

        // Delay supaya animasi kumpul selesai
        run(.sequence([

            .wait(forDuration: 0.4),

            .run { [weak self] in

                guard let self else { return }

                for ball in self.landedBallNodes {

                    ball.run(.sequence([

                        .group([
                            .fadeOut(withDuration: 0.12),
                            .scale(to: 0.7, duration: 0.12)
                        ]),

                        .removeFromParent()
                    ]))
                }

                self.landedBallNodes.removeAll()
            }
        ]))

        turnNumber += 1

        // Delay sedikit supaya visual lebih smooth
        run(.sequence([

            .wait(forDuration: 0.12),

            .run { [weak self] in

                guard let self else { return }
                
                self.isVolleyActive = false
                self.refreshHUD()
                self.placeShooterMarker()
                self.advanceBoard()
            }
        ]))

        // Back to aiming
        run(.sequence([

            .wait(forDuration: 0.62),

            .run { [weak self] in
                self?.stateMachine.enter(GameAimingState.self)
            }
        ]))
    }

    // Moves all blocks/pickups down one row; removes anything that would land at/below
    // the shooter row. Spawns a fresh row at the top after 0.08s.
    func advanceBoard() {
        let allBoardEntities = entityManager.entities(with: BlockTypeComponent.self)
            + entityManager.entities(with: ConsumableComponent.self)

        for entity in allBoardEntities {
            guard let render = entity.component(ofType: RenderComponent.self) else { continue }
            let node = render.node

            let moveDown = SKAction.moveBy(x: 0, y: -step, duration: 0.30)
            moveDown.timingMode = .easeInEaseOut

            // Direct position check — more reliable than rounding-based snapping
            let wouldLandAt = node.position.y - step

            if wouldLandAt <= shootY + cell / 2 {
                // This entity would enter the shooter row — deregister and animate out.
                // untrack() keeps the node in the scene so the animation plays.
                // entityManager.remove() would call removeFromParent() immediately and
                // cancel the animation, making the block disappear instantly (the teleport bug).
                node.physicsBody = nil
                entityManager.untrack(entity)
                node.run(.sequence([
                    moveDown,
                    .fadeOut(withDuration: 0.15),
                    .removeFromParent()
                ]))
            } else {
                node.run(moveDown)
            }
        }

        run(.sequence([
            .wait(forDuration: 0.08),
            .run { [weak self] in self?.spawnRow(0) }
        ]))
    }
    func clampToPlayArea(_ point: CGPoint) -> CGPoint {

        let minX = gridOrigin.x + playAreaInset
        let maxX = gridOrigin.x + gridW - playAreaInset
        let minY = gridOrigin.y + playAreaInset
        let maxY = gridOrigin.y + gridH - playAreaInset

        return CGPoint(
            x: min(max(point.x, minX), maxX),
            y: min(max(point.y, minY), maxY)
        )
    }
}
