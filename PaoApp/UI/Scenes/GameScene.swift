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
    private var cell:       CGFloat = 44
    private let gap:        CGFloat = GameConstants.gap
    private var step:       CGFloat { cell + gap }
    private var gridOrigin: CGPoint = .zero
    private var gridW:      CGFloat = 0
    private var gridH:      CGFloat = 0
    private var shootY:     CGFloat = 0
    private var shootX:     CGFloat = 0

    // MARK: - Game State
    private var ballCount     = GameConstants.initialBallCount
    private var turnNumber    = 0
    private var portalCharges = 0

    // Volley tracking
    private var volleyTotal:  Int      = 0
    private var volleyLanded: Int      = 0
    private var firstLandX:   CGFloat? = nil
    private var shotAngle:    CGFloat  = .pi / 2
    private var lastDT:       TimeInterval = 0

    // Portal warp band positions (set when portal volley is active)
    private var portalEntryY: CGFloat? = nil
    private var portalExitY:  CGFloat? = nil

    // MARK: - ECS
    private var entityManager:   EntityManager!
    private var movementSystem:  MovementSystem!
    private var collisionSystem: CollisionSystem!
    private var healthSystem:    HealthSystem!
    private var controllerSystem: ControllerSystem!

    // MARK: - State Machine
    private var stateMachine: GKStateMachine!

    // MARK: - Player entity (shooter marker)
    private var playerEntity: PlayerEntity?

    // MARK: - HUD Nodes
    private var countLabel:  SKLabelNode!
    private var portalLabel: SKLabelNode!
    private var turnLabel:   SKLabelNode!
    private var nextMarker:  SKShapeNode?

    // MARK: - didMove
    override func didMove(to view: SKView) {
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
        buildBackground()
        buildWalls()
        buildHUD()
        placeShooterMarker()
        spawnInitialRows()
        addPanGesture(to: view)
    }

    // MARK: - Layout (screen-adaptive)

    // Cell size is computed to perfectly fill the available safe area,
    // fixing the prototype's fixed-size scaling issue on different devices.
    private func computeLayout(in view: SKView) {
        let st = max(view.safeAreaInsets.top,    50)
        let sb = max(view.safeAreaInsets.bottom, 34)
        let totalRows = GameConstants.blockRows + 1   // block rows + shooter row

        // Largest cell that fits width: (W - (cols+1)×gap) / cols
        let dynCellW = (frame.width - CGFloat(GameConstants.cols + 1) * gap)
                     / CGFloat(GameConstants.cols)

        // Largest cell that fits height: (H_avail - (rows+1)×gap) / rows
        let availH   = frame.height - st - sb - 56   // 56pt for HUD row + breathing room
        let dynCellH = (availH - CGFloat(totalRows + 1) * gap) / CGFloat(totalRows)

        cell  = floor(min(dynCellW, dynCellH))
        gridW = step * CGFloat(GameConstants.cols) + gap
        gridH = step * CGFloat(totalRows) + gap

        gridOrigin = CGPoint(
            x: frame.midX - gridW / 2,
            y: frame.maxY - st - 16 - gridH
        )
        shootY = cellCenter(col: 0, row: GameConstants.blockRows).y
        shootX = frame.midX
    }

    private func cellCenter(col: Int, row: Int) -> CGPoint {
        CGPoint(
            x: gridOrigin.x + gap + cell / 2 + CGFloat(col) * step,
            y: gridOrigin.y + gridH - gap - cell / 2 - CGFloat(row) * step
        )
    }

    // MARK: - Background

    private func buildBackground() {
        backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.16, alpha: 1)

        // Main grid panel
        let panel = SKShapeNode(
            rect: CGRect(x: gridOrigin.x, y: gridOrigin.y, width: gridW, height: gridH),
            cornerRadius: 14
        )
        panel.fillColor   = UIColor(white: 1, alpha: 0.03)
        panel.strokeColor = UIColor(white: 1, alpha: 0.10)
        panel.lineWidth   = 1.5
        panel.zPosition   = 0
        panel.name        = "ui"
        addChild(panel)

        // Ghost cells for block area
        for r in 0..<GameConstants.blockRows {
            for c in 0..<GameConstants.cols {
                addGhostCell(col: c, row: r, isShooterRow: false)
            }
        }
        // Ghost cells for shooter row
        for c in 0..<GameConstants.cols {
            addGhostCell(col: c, row: GameConstants.blockRows, isShooterRow: true)
        }

        // Divider line between block area and shooter row
        let divY = shootY + cell / 2 + gap / 2
        let div  = SKShapeNode()
        let dp   = CGMutablePath()
        dp.move(to:    CGPoint(x: gridOrigin.x + 10,         y: divY))
        dp.addLine(to: CGPoint(x: gridOrigin.x + gridW - 10, y: divY))
        div.path        = dp
        div.strokeColor = UIColor(red: 0.4, green: 0.65, blue: 1.0, alpha: 0.25)
        div.lineWidth   = 1
        div.name        = "ui"
        addChild(div)
    }

    private func addGhostCell(col: Int, row: Int, isShooterRow: Bool) {
        let g = SKShapeNode(
            rect: CGRect(x: -cell/2, y: -cell/2, width: cell, height: cell),
            cornerRadius: 6
        )
        g.position    = cellCenter(col: col, row: row)
        g.fillColor   = isShooterRow
            ? UIColor(red: 0.4, green: 0.65, blue: 1.0, alpha: 0.04)
            : UIColor(white: 1, alpha: 0.02)
        g.strokeColor = isShooterRow
            ? UIColor(red: 0.4, green: 0.65, blue: 1.0, alpha: 0.15)
            : UIColor(white: 1, alpha: 0.05)
        g.lineWidth   = 0.5
        g.zPosition   = 1
        g.name        = "ui"
        addChild(g)
    }

    // MARK: - Walls (left, right, top — no floor so balls can land)

    private func buildWalls() {
        let l = gridOrigin.x,    r = gridOrigin.x + gridW
        let b = gridOrigin.y,    t = gridOrigin.y + gridH

        let edges: [(CGPoint, CGPoint)] = [
            (CGPoint(x: l, y: b), CGPoint(x: l, y: t)),   // left
            (CGPoint(x: r, y: b), CGPoint(x: r, y: t)),   // right
            (CGPoint(x: l, y: t), CGPoint(x: r, y: t))    // top
        ]

        for (a, b) in edges {
            let wall = SKNode()
            wall.physicsBody = SKPhysicsBody(edgeFrom: a, to: b)
            wall.physicsBody?.friction         = 0
            wall.physicsBody?.restitution      = 1
            wall.physicsBody?.categoryBitMask  = PhysicsCategory.wall
            wall.physicsBody?.collisionBitMask = PhysicsCategory.ball
            wall.name = "wall"
            addChild(wall)
        }
    }

    // MARK: - HUD

    private func buildHUD() {
        let iconSize = GameConstants.ballRadius * 2
        let iconX    = gridOrigin.x + gap + iconSize / 2 + 2

        // Ball icon indicator — same bakpao asset as the thrown ball
        let ballIcon = SKSpriteNode(imageNamed: "bakpaoAmmo")
        ballIcon.size     = CGSize(width: iconSize, height: iconSize)
        ballIcon.position = CGPoint(x: iconX, y: shootY)
        ballIcon.zPosition = 10
        ballIcon.name     = "ui"
        addChild(ballIcon)

        // Ball count label
        countLabel = SKLabelNode(fontNamed: GameConstants.fontName)
        countLabel.fontSize                = 16
        countLabel.fontColor               = UIColor(white: 0.9, alpha: 1)
        countLabel.text                    = "×\(ballCount)"
        countLabel.horizontalAlignmentMode = .left
        countLabel.verticalAlignmentMode   = .center
        countLabel.position                = CGPoint(x: iconX + iconSize / 2 + 6, y: shootY)
        countLabel.zPosition               = 10
        addChild(countLabel)

        // Portal charge indicator (hidden until collected)
        portalLabel = SKLabelNode(fontNamed: GameConstants.fontName)
        portalLabel.fontSize                = 14
        portalLabel.fontColor               = UIColor(red: 0.72, green: 0.50, blue: 1.0, alpha: 1)
        portalLabel.text                    = ""
        portalLabel.horizontalAlignmentMode = .left
        portalLabel.verticalAlignmentMode   = .center
        portalLabel.position                = CGPoint(x: iconX + iconSize / 2 + 52, y: shootY)
        portalLabel.zPosition               = 10
        addChild(portalLabel)

        // Turn counter
        turnLabel = SKLabelNode(fontNamed: GameConstants.fontName)
        turnLabel.fontSize                = 13
        turnLabel.fontColor               = UIColor(white: 0.5, alpha: 1)
        turnLabel.text                    = "TURN 1"
        turnLabel.horizontalAlignmentMode = .right
        turnLabel.verticalAlignmentMode   = .center
        turnLabel.position                = CGPoint(x: gridOrigin.x + gridW - 6, y: shootY)
        turnLabel.zPosition               = 10
        addChild(turnLabel)
    }

    private func refreshHUD() {
        countLabel.text = "×\(ballCount)"
        countLabel.run(.sequence([
            .scale(to: 1.5, duration: 0.07),
            .scale(to: 1.0, duration: 0.10)
        ]))
        turnLabel.text  = "TURN \(turnNumber + 1)"
        portalLabel.text = portalCharges > 0 ? "⬡ ×\(portalCharges)" : ""
    }

    // MARK: - Shooter Marker

    private func placeShooterMarker() {
        // Remove previous player entity
        if let prev = playerEntity {
            entityManager.remove(prev)
        }

        let node = PlayerNode(radius: GameConstants.ballRadius)
        node.position = CGPoint(x: shootX, y: shootY)

        let entity = PlayerEntity(node: node)
        entityManager.add(entity)
        playerEntity = entity
    }

    // MARK: - Block / Pickup Spawning

    private func spawnInitialRows() {
        for r in 0...2 { spawnRow(r) }
    }

    private func spawnRow(_ row: Int) {
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
                let type = RandomManager.shared.randomBlockType(turnNumber: turnNumber)
                addBlockEntity(at: pos, type: type, hp: hp)
            } else if c == ammoCol {
                addPickupEntity(at: pos, type: .ammo)
            } else if c == portalCol {
                addPickupEntity(at: pos, type: .portalToken)
            }
        }
    }

    private func addBlockEntity(at pos: CGPoint, type: BlockType, hp: Int) {
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

    private func addPickupEntity(at pos: CGPoint, type: PickupType) {
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

    // MARK: - Gesture (Aiming)

    private func addPanGesture(to view: SKView) {
        view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        )
    }

    @objc private func onPan(_ g: UIPanGestureRecognizer) {
        guard stateMachine.currentState is GameAimingState else { return }

        let raw   = g.translation(in: view)
        let angle = clampAngle(dx: raw.x, dy: -raw.y)

        switch g.state {
        case .began, .changed:
            controllerSystem.updateAimLine(
                from: CGPoint(x: shootX, y: shootY),
                angle: angle,
                topY: gridOrigin.y + gridH
            )
            // Store angle in player control component
            playerEntity?.component(ofType: ControlComponent.self)?.shotAngle = angle

        case .ended, .cancelled:
            controllerSystem.removeAimLine()
            shotAngle = angle
            startVolley(angle: angle)

        default:
            break
        }
    }

    // Clamps angle to at least 8° from horizontal so balls always move upward
    private func clampAngle(dx: CGFloat, dy: CGFloat) -> CGFloat {
        let min8 = CGFloat(8) * .pi / 180
        var a    = atan2(dy, dx)
        if dy <= 0 { a = dx >= 0 ? min8 : .pi - min8 }
        else       { a = Swift.min(Swift.max(a, min8), .pi - min8) }
        return a
    }

    // MARK: - Volley

    private func startVolley(angle: CGFloat) {
        shotAngle    = angle
        volleyTotal  = ballCount
        volleyLanded = 0
        firstLandX   = nil

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

    private func fireOneBall() {
        let node = BallNode(radius: GameConstants.ballRadius)
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
    private func activatePortalVolley() {
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

    private func clearPortalRings() {
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

    private func handleBlockHit(node: SKNode) {
        guard let entity = entityManager.entity(forNode: node) else { return }

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

    private func animateBlockDeath(node: SKNode, isBomb: Bool) {
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

    private func explode(at pos: CGPoint) {
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

    private func handlePickupCollected(node: SKNode) {
        guard let entity = entityManager.entity(forNode: node) else { return }
        guard let consumable = entity.component(ofType: ConsumableComponent.self) else { return }

        // Deregister and remove physics so the same pickup can't be collected twice
        entityManager.untrack(entity)
        node.physicsBody = nil
        node.removeFromParent()

        switch consumable.pickupType {
        case .ammo:
            ballCount += 1
            refreshHUD()
            HapticManager.shared.play(.medium)
            floatLabel("+1", at: node.position, color: UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 1))

        case .portalToken:
            portalCharges += 1
            refreshHUD()
            HapticManager.shared.play(.heavy)
            floatLabel("⬡ portal!", at: node.position, color: UIColor(red: 0.72, green: 0.50, blue: 1.0, alpha: 1))
        }
    }

    private func floatLabel(_ text: String, at pos: CGPoint, color: UIColor) {
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

    private func ballLanded(entity: GKEntity, ball: SKSpriteNode) {
        // Record first landing X as the new shooter position
        if firstLandX == nil {
            let lo = gridOrigin.x + GameConstants.ballRadius + gap
            let hi = gridOrigin.x + gridW - GameConstants.ballRadius - gap
            firstLandX = Swift.min(Swift.max(ball.position.x, lo), hi)
            showNextMarker(x: firstLandX!)
        }

        ball.physicsBody?.velocity = .zero
        ball.physicsBody = nil

        // Deregister from ECS before starting fade — entityManager.remove() would call
        // removeFromParent() immediately and cancel the fade-out animation.
        entityManager.untrack(entity)

        ball.run(.sequence([
            .fadeOut(withDuration: 0.10),
            .removeFromParent()
        ]))

        volleyLanded += 1
        if volleyLanded >= volleyTotal { endVolley() }
    }

    private func showNextMarker(x: CGFloat) {
        nextMarker?.removeFromParent()
        let dot = SKShapeNode(circleOfRadius: GameConstants.ballRadius * 0.7)
        dot.fillColor   = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.25)
        dot.strokeColor = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.65)
        dot.lineWidth   = 1.5
        dot.position    = CGPoint(x: x, y: shootY)
        dot.zPosition   = 4
        dot.name        = "ui"
        addChild(dot)
        nextMarker = dot
    }

    // MARK: - End Volley / Advance Board

    private func endVolley() {
        if let lx = firstLandX { shootX = lx }
        firstLandX = nil

        stateMachine.enter(GameTurnEndState.self)

        clearPortalRings()
        nextMarker?.removeFromParent()
        nextMarker = nil

        turnNumber += 1
        refreshHUD()
        placeShooterMarker()
        advanceBoard()

        // Brief delay, then return to aiming
        run(.sequence([
            .wait(forDuration: 0.45),
            .run { [weak self] in self?.stateMachine.enter(GameAimingState.self) }
        ]))
    }

    // Moves all blocks/pickups down one row; removes anything that would land at/below
    // the shooter row. Spawns a fresh row at the top after 0.08s.
    private func advanceBoard() {
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
}
