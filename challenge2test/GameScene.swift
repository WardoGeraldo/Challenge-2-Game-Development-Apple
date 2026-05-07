//
//  GameScene.swift
//  challenge2test
//
//  Created by Edward Geraldo Kristian on 30/04/26.
import SpriteKit
import UIKit
import GameplayKit

// MARK: - Physics bitmasks
private enum Mask {
    static let ball:   UInt32 = 1
    static let block:  UInt32 = 2
    static let wall:   UInt32 = 4
    static let ammo:   UInt32 = 16
    static let pickup: UInt32 = 32   // any floor pickup (ammo, portal token)
}
// MARK: - Pickup type (spawns in empty slots)
private enum PickupType {
    case ammo
    case portalToken   // rare — when collected, next shot warps through a portal
}
// MARK: - Block type (destructible, sits in grid)
private enum BlockType {
    case normal
    case triangle(flipped: Bool)   // unlocks turn 5
    case bomb                      // unlocks turn 10
    case rover                     // moves left/right — unlocks turn 3
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    // ── Grid ──────────────────────────────────
    private let cols      = 7
    private let blockRows = 9
    private let cell:  CGFloat = 44
    private let gap:   CGFloat = 5
    private var step:  CGFloat { cell + gap }
    // ── Ball ──────────────────────────────────
    private let ballR:     CGFloat      = 9
    private let ballSpeed: CGFloat      = 400
    private let shootGap:  TimeInterval = 0.13
    // ── State ─────────────────────────────────
    private var ballCount  = 3
    private var turnNumber = 0
    private var flying     = false
    private var aiming     = false
    private var volleyTotal:  Int      = 0
    private var volleyLanded: Int      = 0
    private var firstLandX:   CGFloat? = nil
    private var shotAngle:    CGFloat  = .pi / 2
    private var ballsRisen:   Set<ObjectIdentifier> = []
    private var lastDT:     TimeInterval = 0
    // ── Haptics ───────────────────────────────
    // Light impact for normal block hit, medium for low-HP block, heavy for kill + bomb
    private let hapticLight  = UIImpactFeedbackGenerator(style: .light)
    private let hapticMedium = UIImpactFeedbackGenerator(style: .medium)
    private let hapticHeavy  = UIImpactFeedbackGenerator(style: .heavy)
    private let hapticRigid  = UIImpactFeedbackGenerator(style: .rigid)
    // ── Portal token state ────────────────────
    // When player collects a portal token, the NEXT volley gets a mid-air
    // warp: balls teleport from one random Y band to another.
    // We store the portal token as a HUD indicator only — no complex registry needed.
    private var portalCharges = 0      // how many portal-volleys the player has stored
    // ── Rover ─────────────────────────────────
    private let roverSpeed: CGFloat = 30   // pts/sec
    // ── Geometry ──────────────────────────────
    private var gridOrigin = CGPoint.zero
    private var gridW: CGFloat = 0
    private var gridH: CGFloat = 0
    private var shootY: CGFloat = 0
    private var shootX: CGFloat = 0
    // ── Nodes ─────────────────────────────────
    private var shooterBall:   SKSpriteNode!
    private var aimLine:       SKShapeNode?
    private var countLabel:    SKLabelNode!
    private var portalLabel:   SKLabelNode!
    private var nextMarker:    SKShapeNode?
    private var turnLabel:     SKLabelNode!
    // Block Randomization
    let blockTierDistribution = GKShuffledDistribution(lowestValue: 1, highestValue: 10)
    // ─────────────────────────────────────────
    // MARK: didMove
    // ─────────────────────────────────────────
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.16, alpha: 1)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        hapticLight.prepare()
        hapticMedium.prepare()
        hapticHeavy.prepare()
        hapticRigid.prepare()
        computeLayout(in: view)
        buildBackground()
        buildWalls()
        buildHUD()
        placeShooterBall()
        spawnInitialRows()
        addPanGesture(to: view)
    }
    // ─────────────────────────────────────────
    // MARK: Layout
    // ─────────────────────────────────────────
    private func computeLayout(in view: SKView) {
        let totalRows = blockRows + 1
        gridW = step * CGFloat(cols)      + gap
        gridH = step * CGFloat(totalRows) + gap
        let st = view.safeAreaInsets.top    > 0 ? view.safeAreaInsets.top    : 50
        let sb = view.safeAreaInsets.bottom > 0 ? view.safeAreaInsets.bottom : 34
        gridOrigin = CGPoint(x: frame.midX - gridW / 2,
                             y: frame.maxY - st - 16 - gridH)
        shootY = cellCenter(col: 0, row: blockRows).y
        shootX = frame.midX
        _ = sb
    }
    private func cellCenter(col: Int, row: Int) -> CGPoint {
        CGPoint(
            x: gridOrigin.x + gap + cell / 2 + CGFloat(col) * step,
            y: gridOrigin.y + gridH - gap - cell / 2 - CGFloat(row) * step
        )
    }
    // ─────────────────────────────────────────
    // MARK: Background
    // ─────────────────────────────────────────
    private func buildBackground() {
        let panel = SKShapeNode(
            rect: CGRect(x: gridOrigin.x, y: gridOrigin.y,
                         width: gridW, height: gridH), cornerRadius: 14)
        panel.fillColor   = UIColor(white: 1, alpha: 0.03)
        panel.strokeColor = UIColor(white: 1, alpha: 0.10)
        panel.lineWidth   = 1.5; panel.zPosition = 0; panel.name = "ui"
        addChild(panel)
        for r in 0..<blockRows {
            for c in 0..<cols { ghostCell(col: c, row: r, shooter: false) }
        }
        for c in 0..<cols { ghostCell(col: c, row: blockRows, shooter: true) }
        let divY = shootY + cell / 2 + gap / 2
        let div  = SKShapeNode(); let dp = CGMutablePath()
        dp.move(to:    CGPoint(x: gridOrigin.x + 10,         y: divY))
        dp.addLine(to: CGPoint(x: gridOrigin.x + gridW - 10, y: divY))
        div.path        = dp
        div.strokeColor = UIColor(red: 0.4, green: 0.65, blue: 1.0, alpha: 0.25)
        div.lineWidth   = 1; div.name = "ui"
        addChild(div)
    }
    private func ghostCell(col: Int, row: Int, shooter: Bool) {
        let g = SKShapeNode(
            rect: CGRect(x: -cell/2, y: -cell/2, width: cell, height: cell),
            cornerRadius: 6)
        g.position    = cellCenter(col: col, row: row)
        g.fillColor   = shooter
            ? UIColor(red: 0.4, green: 0.65, blue: 1.0, alpha: 0.04)
            : UIColor(white: 1, alpha: 0.02)
        g.strokeColor = shooter
            ? UIColor(red: 0.4, green: 0.65, blue: 1.0, alpha: 0.15)
            : UIColor(white: 1, alpha: 0.05)
        g.lineWidth = 0.5; g.zPosition = 1; g.name = "ui"
        addChild(g)
    }
    // ─────────────────────────────────────────
    // MARK: Walls — left + right + top only
    // ─────────────────────────────────────────
    private func buildWalls() {
        let l = gridOrigin.x, r = gridOrigin.x + gridW
        let b = gridOrigin.y, t = gridOrigin.y + gridH
        for (a, bPt) in [
            (CGPoint(x:l,y:b), CGPoint(x:l,y:t)),
            (CGPoint(x:r,y:b), CGPoint(x:r,y:t)),
            (CGPoint(x:l,y:t), CGPoint(x:r,y:t))
        ] {
            let n = SKNode()
            n.physicsBody = SKPhysicsBody(edgeFrom: a, to: bPt)
            n.physicsBody?.friction         = 0
            n.physicsBody?.restitution      = 1
            n.physicsBody?.categoryBitMask  = Mask.wall
            n.physicsBody?.collisionBitMask = Mask.ball
            n.name = "wall"; addChild(n)
        }
    }
    // ─────────────────────────────────────────
    // MARK: HUD
    // ─────────────────────────────────────────
    private func buildHUD() {
        let iconX = gridOrigin.x + gap + ballR + 2
        // Ball circle icon
        let ballIcon = SKShapeNode(circleOfRadius: ballR)
        ballIcon.fillColor   = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 1)
        ballIcon.strokeColor = .clear
        ballIcon.position    = CGPoint(x: iconX, y: shootY)
        ballIcon.zPosition   = 10; ballIcon.name = "ui"
        addChild(ballIcon)
        countLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countLabel.fontSize                = 16
        countLabel.fontColor               = UIColor(white: 0.9, alpha: 1)
        countLabel.text                    = "×\(ballCount)"
        countLabel.horizontalAlignmentMode = .left
        countLabel.verticalAlignmentMode   = .center
        countLabel.position  = CGPoint(x: iconX + ballR + 6, y: shootY)
        countLabel.zPosition = 10
        addChild(countLabel)
        // Portal charge indicator — hidden until player collects one
        portalLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        portalLabel.fontSize                = 14
        portalLabel.fontColor               = UIColor(red: 0.72, green: 0.50, blue: 1.0, alpha: 1)
        portalLabel.text                    = ""
        portalLabel.horizontalAlignmentMode = .left
        portalLabel.verticalAlignmentMode   = .center
        portalLabel.position  = CGPoint(x: iconX + ballR + 52, y: shootY)
        portalLabel.zPosition = 10
        addChild(portalLabel)
        turnLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        turnLabel.fontSize                = 13
        turnLabel.fontColor               = UIColor(white: 0.5, alpha: 1)
        turnLabel.text                    = "TURN 1"
        turnLabel.horizontalAlignmentMode = .right
        turnLabel.verticalAlignmentMode   = .center
        turnLabel.position  = CGPoint(x: gridOrigin.x + gridW - 6, y: shootY)
        turnLabel.zPosition = 10
        addChild(turnLabel)
    }
    private func refreshHUD() {
        countLabel.text = "×\(ballCount)"
        countLabel.run(.sequence([.scale(to: 1.5, duration: 0.07), .scale(to: 1.0, duration: 0.10)]))
        turnLabel.text  = "TURN \(turnNumber + 1)"
        portalLabel.text = portalCharges > 0 ? "⬡ ×\(portalCharges)" : ""
    }
    // ─────────────────────────────────────────
    // MARK: Shooter ball — rendered circle
    // ─────────────────────────────────────────
    private func placeShooterBall() {
        shooterBall?.removeFromParent()
        shooterBall          = makeBallNode()
        shooterBall.position = CGPoint(x: shootX, y: shootY)
        addChild(shooterBall)
    }
    private func makeBallNode() -> SKSpriteNode {
        let diameter = Int(ballR * 2)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        let img = renderer.image { ctx in
            UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 1).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: diameter, height: diameter))
            UIColor(white: 1, alpha: 0.45).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: diameter/4, y: diameter/4,
                                                  width: diameter/3, height: diameter/3))
        }
        let b = SKSpriteNode(texture: SKTexture(image: img),
                             size: CGSize(width: ballR*2, height: ballR*2))
        b.name = "ball"; b.zPosition = 7
        let body = SKPhysicsBody(circleOfRadius: ballR)
        body.friction           = 0
        body.linearDamping      = 0
        body.restitution        = 1
        body.allowsRotation     = false
        body.isDynamic          = true
        body.categoryBitMask    = Mask.ball
        body.collisionBitMask   = Mask.wall | Mask.block
        body.contactTestBitMask = Mask.block | Mask.pickup
        b.physicsBody = body
        return b
    }
    // ─────────────────────────────────────────
    // MARK: Spawn board
    // ─────────────────────────────────────────
    private func spawnInitialRows() {
        for r in 0...2 { spawnRow(r) }
    }
    private func spawnRow(_ row: Int) {
        guard row < blockRows else { return }
        let shuffled  = Array(0..<cols).shuffled()
        let nBlocks   = Int.random(in: 2...4)
        let bCols     = Set(shuffled.prefix(nBlocks))
        var emptyCols = shuffled.filter { !bCols.contains($0) }.shuffled()
        // ── Decide pickups for empty slots ────
        // Ammo: 45% chance one spawns (reduced over time, min 20%)
        let ammoChance   = max(20, 45 - turnNumber * 2)
        var ammoCol:   Int? = Int.random(in: 0...99) < ammoChance   ? emptyCols.first : nil
        if ammoCol != nil { emptyCols.removeFirst() }
        // Portal token: rare — 12% base chance, only after turn 6, max 1 per row
        let portalChance = turnNumber >= 6 ? 12 : 0
        var portalCol: Int? = (!emptyCols.isEmpty && Int.random(in: 0...99) < portalChance)
                                ? emptyCols.first : nil
        if portalCol != nil && !emptyCols.isEmpty { emptyCols.removeFirst() }
        for c in 0..<cols {
            let pos = cellCenter(col: c, row: row)
            if bCols.contains(c) {
                // Assign the result to a constant named fairHP
                let fairHP = generateBalancedBlockHP(currentAmmo: ballCount)
                
                // Pass fairHP into the block builder
                addBlock(at: pos, type: randomBlockType(), hp: fairHP)
                
            } else if c == ammoCol {
                addPickup(at: pos, type: .ammo)
            } else if c == portalCol {
                addPickup(at: pos, type: .portalToken)
            }
        }
    }
    // ─────────────────────────────────────────
    // MARK: Block type selection
    // ─────────────────────────────────────────
    private func randomBlockType() -> BlockType {
        let hasRover    = turnNumber >= 3
        let hasTriangle = turnNumber >= 5
        let hasBomb     = turnNumber >= 10
        let roll = Int.random(in: 0...99)
        if hasBomb     && roll < 10 { return .bomb }
        if hasTriangle && roll < 28 { return .triangle(flipped: Bool.random()) }
        if hasRover    && roll < 20 { return .rover }
        return .normal
    }
    // ─────────────────────────────────────────
    // MARK: Block builders
    // ─────────────────────────────────────────
    private func addBlock(at pos: CGPoint, type: BlockType, hp: Int) {
        let node = SKNode()
        node.position  = pos
        node.name      = "block"
        node.zPosition = 3
        
        switch type {
        case .normal:              buildNormalBlock(node: node, hp: hp)
        case .triangle(let flip):  buildTriangleBlock(node: node, hp: hp, flipped: flip)
        case .bomb:                buildBombBlock(node: node, hp: hp)
        case .rover:               buildRoverBlock(node: node, hp: hp)
        }
        
        node.alpha = 0
        node.setScale(0.2)
        addChild(node)
        
        node.run(.group([.fadeIn(withDuration: 0.35), .scale(to: 1.0, duration: 0.35)]))
    }
    
    private func buildNormalBlock(node: SKNode, hp: Int) {
        let sprite = SKSpriteNode(color: blockFill(hp: hp),
                                  size: CGSize(width: cell, height: cell))
        sprite.name = "blockSprite"
        let corner = SKShapeNode(
            rect: CGRect(x: -cell/2, y: -cell/2, width: cell, height: cell),
            cornerRadius: 7)
        corner.fillColor   = .clear
        corner.strokeColor = UIColor(white: 1, alpha: 0.12)
        corner.lineWidth   = 1; corner.zPosition = 1
        let body = SKPhysicsBody(rectangleOf: CGSize(width: cell, height: cell))
        body.isDynamic = false; body.friction = 0; body.restitution = 1
        body.categoryBitMask    = Mask.block
        body.collisionBitMask   = Mask.ball
        body.contactTestBitMask = Mask.ball
        node.physicsBody = body
        node.addChild(sprite); node.addChild(corner)
        node.addChild(hpLabel(hp: hp, fontSize: cell * 0.38))
    }
    private func buildTriangleBlock(node: SKNode, hp: Int, flipped: Bool) {
        let h = cell
        let path = CGMutablePath()
        if flipped {
            path.move(to: CGPoint(x: -h/2, y: -h/2))
            path.addLine(to: CGPoint(x:  h/2, y: -h/2))
            path.addLine(to: CGPoint(x:  h/2, y:  h/2))
        } else {
            path.move(to: CGPoint(x: -h/2, y: -h/2))
            path.addLine(to: CGPoint(x:  h/2, y: -h/2))
            path.addLine(to: CGPoint(x: -h/2, y:  h/2))
        }
        path.closeSubpath()
        let shape = SKShapeNode(path: path)
        shape.fillColor   = UIColor(red: 0.85, green: 0.62, blue: 0.20, alpha: 1)
        shape.strokeColor = UIColor(white: 1, alpha: 0.18)
        shape.lineWidth   = 1; shape.name = "blockSprite"
        var pts: [CGPoint] = flipped
            ? [CGPoint(x:-h/2,y:-h/2), CGPoint(x:h/2,y:-h/2), CGPoint(x:h/2,y:h/2)]
            : [CGPoint(x:-h/2,y:-h/2), CGPoint(x:h/2,y:-h/2), CGPoint(x:-h/2,y:h/2)]
        let body = SKPhysicsBody(polygonFrom: CGPath.polygon(points: pts))
        body.isDynamic = false; body.friction = 0; body.restitution = 1
        body.categoryBitMask    = Mask.block
        body.collisionBitMask   = Mask.ball
        body.contactTestBitMask = Mask.ball
        node.physicsBody = body
        node.addChild(shape)
        node.addChild(hpLabel(hp: hp, fontSize: cell * 0.30))
    }
    private func buildBombBlock(node: SKNode, hp: Int) {
        let sprite = SKSpriteNode(color: UIColor(red: 0.85, green: 0.22, blue: 0.22, alpha: 1),
                                  size: CGSize(width: cell, height: cell))
        sprite.name = "blockSprite"
        node.userData = NSMutableDictionary(); node.userData?["bomb"] = true
        let glow = SKShapeNode(
            rect: CGRect(x: -cell/2, y: -cell/2, width: cell, height: cell), cornerRadius: 7)
        glow.fillColor   = .clear
        glow.strokeColor = UIColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 0.5)
        glow.lineWidth   = 2; glow.zPosition = 1
        glow.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.15, duration: 0.7), .fadeAlpha(to: 0.8, duration: 0.7)
        ])))
        let icon = SKLabelNode(text: "💣")
        icon.fontSize = cell * 0.38; icon.verticalAlignmentMode = .center
        icon.position = CGPoint(x: 0, y: cell * 0.08)
        let body = SKPhysicsBody(rectangleOf: CGSize(width: cell, height: cell))
        body.isDynamic = false; body.friction = 0; body.restitution = 1
        body.categoryBitMask    = Mask.block
        body.collisionBitMask   = Mask.ball
        body.contactTestBitMask = Mask.ball
        node.physicsBody = body
        node.addChild(sprite); node.addChild(glow); node.addChild(icon)
        node.addChild(hpLabel(hp: hp, fontSize: cell * 0.28, offsetY: -cell * 0.24))
    }
    // ── Rover block ───────────────────────────
    // A teal destructible block that slides left/right.
    // Reverses on hitting a wall or another block.
    // Gets wedged (stuck) when blocked on both sides.
    // Automatically un-sticks when a neighbour block is destroyed.
    private func buildRoverBlock(node: SKNode, hp: Int) {
        let sprite = SKSpriteNode(color: UIColor(red: 0.15, green: 0.58, blue: 0.52, alpha: 1),
                                  size: CGSize(width: cell, height: cell))
        sprite.name = "blockSprite"
        node.userData = NSMutableDictionary()
        node.userData?["rover"] = true
        node.userData?["dir"]   = (Bool.random() ? 1 : -1)   // start moving either way
        node.userData?["stuck"] = false
        // Corner overlay
        let corner = SKShapeNode(
            rect: CGRect(x: -cell/2, y: -cell/2, width: cell, height: cell), cornerRadius: 7)
        corner.fillColor   = .clear
        corner.strokeColor = UIColor(white: 1, alpha: 0.14)
        corner.lineWidth   = 1; corner.zPosition = 1
        // Left/right arrows showing it moves
        let arrow = SKLabelNode(text: "⟷")
        arrow.fontSize              = cell * 0.30
        arrow.fontColor             = UIColor(white: 1, alpha: 0.65)
        arrow.verticalAlignmentMode = .center
        arrow.position              = CGPoint(x: 0, y: cell * 0.08)
        let body = SKPhysicsBody(rectangleOf: CGSize(width: cell, height: cell))
        body.isDynamic          = false
        body.friction           = 0
        body.restitution        = 1
        body.categoryBitMask    = Mask.block
        body.collisionBitMask   = Mask.ball
        body.contactTestBitMask = Mask.ball
        node.physicsBody = body
        node.addChild(sprite); node.addChild(corner); node.addChild(arrow)
        node.addChild(hpLabel(hp: hp, fontSize: cell * 0.30, offsetY: -cell * 0.20))
    }
    
    func generateBalancedBlockHP(currentAmmo: Int) -> Int {
        // 1. Draw a card from the deck (guarantees no streaks)
        let roll = blockTierDistribution.nextInt()
        
        let baseMultiplier: Double
        
        // 2. Map the drawn card to your team's exact formula
        if roll <= 6 {
            // Cards 1-6 (60% chance): Half ammo
            baseMultiplier = 0.5
        } else if roll <= 9 {
            // Cards 7-9 (30% chance): Full ammo
            baseMultiplier = 1.0
        } else {
            // Card 10 (10% chance): 150% ammo
            // Because this is a shuffled deck, you CANNOT draw this again
            // until the other 9 cards are drawn.
            baseMultiplier = 1.5
        }
        
        // 3. Calculate the base HP
        let baseHP = Double(currentAmmo) * baseMultiplier
        
        // 4. Apply the ± 0-2 variance
        let variance = Int.random(in: -2...2)
        
        // 5. Ensure the block always has at least 1 HP
        return max(1, Int(round(baseHP)) + variance)
    }
    
    // ─────────────────────────────────────────
    // MARK: Pickup builders (ammo + portal token)
    // ─────────────────────────────────────────
    private func addPickup(at pos: CGPoint, type: PickupType) {
        switch type {
        case .ammo:        addAmmoPickup(at: pos)
        case .portalToken: addPortalPickup(at: pos)
        }
    }
    private func addAmmoPickup(at pos: CGPoint) {
        let r    = ballR * 0.85
        let node = SKShapeNode(circleOfRadius: r)
        node.fillColor   = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.9)
        node.strokeColor = UIColor(white: 1, alpha: 0.6)
        node.lineWidth   = 1.5
        node.position    = pos; node.name = "pickup_ammo"; node.zPosition = 3
        let inner = SKShapeNode(circleOfRadius: r * 0.45)
        inner.fillColor = UIColor(white: 1, alpha: 0.6); inner.strokeColor = .clear
        node.addChild(inner)
        let body = SKPhysicsBody(circleOfRadius: r)
        body.isDynamic          = false
        body.categoryBitMask    = Mask.pickup
        body.collisionBitMask   = 0
        body.contactTestBitMask = Mask.ball
        node.physicsBody = body
        node.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 3, duration: 0.6), .moveBy(x: 0, y: -3, duration: 0.6)
        ])))
        node.run(.repeatForever(.sequence([
            .scale(to: 1.10, duration: 0.9), .scale(to: 0.92, duration: 0.9)
        ])))
        addChild(node)
    }
    // Portal token: purple hexagon pickup — rare, glows and pulses
    private func addPortalPickup(at pos: CGPoint) {
        let size = cell * 0.46
        // Hexagon shape
        let hex  = hexagonPath(radius: size)
        let node = SKShapeNode(path: hex)
        node.fillColor   = UIColor(red: 0.30, green: 0.15, blue: 0.60, alpha: 0.95)
        node.strokeColor = UIColor(red: 0.72, green: 0.50, blue: 1.00, alpha: 0.90)
        node.lineWidth   = 2
        node.position    = pos; node.name = "pickup_portal"; node.zPosition = 3
        // Inner swirl ring
        let ring = SKShapeNode(circleOfRadius: size * 0.55)
        ring.fillColor   = .clear
        ring.strokeColor = UIColor(red: 0.80, green: 0.65, blue: 1.0, alpha: 0.70)
        ring.lineWidth   = 1.5
        ring.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 2.4)))
        node.addChild(ring)
        // Glyph
        let glyph = SKLabelNode(text: "⬡")
        glyph.fontSize              = size * 1.1
        glyph.fontColor             = UIColor(red: 0.85, green: 0.72, blue: 1.0, alpha: 1)
        glyph.verticalAlignmentMode = .center
        node.addChild(glyph)
        let body = SKPhysicsBody(circleOfRadius: size)
        body.isDynamic          = false
        body.categoryBitMask    = Mask.pickup
        body.collisionBitMask   = 0
        body.contactTestBitMask = Mask.ball
        node.physicsBody = body
        // Pulse + slow float
        node.run(.repeatForever(.sequence([
            .group([
                .sequence([.moveBy(x: 0, y: 4, duration: 0.8), .moveBy(x: 0, y: -4, duration: 0.8)]),
                .sequence([.scale(to: 1.12, duration: 0.8), .scale(to: 0.90, duration: 0.8)])
            ])
        ])))
        // Slow rotate
        node.run(.repeatForever(.rotate(byAngle: -.pi * 2, duration: 6)))
        addChild(node)
    }
    // Helper: build a regular hexagon CGPath centred at origin
    private func hexagonPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let pt    = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }
    // ─────────────────────────────────────────
    // MARK: HP + colour helpers
    // ─────────────────────────────────────────
    private func blockHP() -> Int {
        let roll = Int.random(in: 1...100)
        let base: Double
        switch roll {
        case ...60: base = Double(ballCount) * 0.5
        case ...90: base = Double(ballCount)
        default:    base = Double(ballCount) * 1.5
        }
        let turn = Double(turnNumber) * 0.3
        return max(1, Int(round(base + turn)) + Int.random(in: -1...1))
    }
    private func blockFill(hp: Int) -> UIColor {
        let ratio = CGFloat(hp) / CGFloat(max(ballCount, 1))
        switch ratio {
        case ..<0.6: return UIColor(red: 0.20, green: 0.72, blue: 0.55, alpha: 1)  // teal
        case ..<1.0: return UIColor(red: 0.85, green: 0.65, blue: 0.15, alpha: 1)  // amber
        default:     return UIColor(red: 0.85, green: 0.28, blue: 0.22, alpha: 1)  // red
        }
    }
    private func hpLabel(hp: Int, fontSize: CGFloat, offsetY: CGFloat = 0) -> SKLabelNode {
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.name = "hp"; lbl.text = "\(hp)"; lbl.fontSize = fontSize
        lbl.fontColor = .white
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center
        lbl.position = CGPoint(x: 0, y: offsetY)
        return lbl
    }
    // ─────────────────────────────────────────
    // MARK: Pan gesture + aiming
    // ─────────────────────────────────────────
    private func addPanGesture(to view: SKView) {
        view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(onPan(_:))))
    }
    @objc private func onPan(_ g: UIPanGestureRecognizer) {
        guard !flying else { return }
        let raw   = g.translation(in: view)
        let angle = clampAngle(dx: raw.x, dy: -raw.y)
        switch g.state {
        case .began:
            aiming = true; drawAimLine(angle)
        case .changed:
            if aiming { updateAimLine(angle) }
        case .ended, .cancelled:
            guard aiming else { return }
            aiming = false; removeAimLine()
            startVolley(angle: angle)
        default: break
        }
    }
    private func clampAngle(dx: CGFloat, dy: CGFloat) -> CGFloat {
        let min8 = CGFloat(8) * .pi / 180
        var a    = atan2(dy, dx)
        if dy <= 0 { a = dx >= 0 ? min8 : .pi - min8 }
        else       { a = Swift.min(Swift.max(a, min8), .pi - min8) }
        return a
    }
    // ─────────────────────────────────────────
    // MARK: Aim line
    // ─────────────────────────────────────────
    private func drawAimLine(_ angle: CGFloat) {
        aimLine              = SKShapeNode()
        aimLine?.strokeColor = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.5)
        aimLine?.lineWidth   = 2
        aimLine?.zPosition   = 9; aimLine?.name = "ui"
        addChild(aimLine!)
        updateAimLine(angle)
    }
    private func updateAimLine(_ angle: CGFloat) {
        guard let ln = aimLine else { return }
        let o   = shooterBall.position
        let len = (gridOrigin.y + gridH) - o.y + 10
        let p   = CGMutablePath()
        p.move(to: o)
        p.addLine(to: CGPoint(x: o.x + cos(angle)*len, y: o.y + sin(angle)*len))
        ln.path = p.copy(dashingWithPhase: 0, lengths: [10, 8])
    }
    private func removeAimLine() { aimLine?.removeFromParent(); aimLine = nil }
    // ─────────────────────────────────────────
    // MARK: Volley
    // ─────────────────────────────────────────
    private func startVolley(angle: CGFloat) {
        shotAngle    = angle
        volleyTotal  = ballCount
        volleyLanded = 0
        firstLandX   = nil
        flying       = true
        ballsRisen.removeAll()
        // If player has a portal charge, activate warp effect for this volley
        if portalCharges > 0 {
            portalCharges -= 1
            refreshHUD()
            activatePortalVolley()
        }
        launch(shooterBall, angle: angle)
        for i in 1..<volleyTotal {
            run(.sequence([
                .wait(forDuration: TimeInterval(i) * shootGap),
                .run { [weak self] in
                    guard let s = self else { return }
                    let b      = s.makeBallNode()
                    b.position = CGPoint(x: s.shootX, y: s.shootY)
                    s.addChild(b)
                    s.launch(b, angle: s.shotAngle)
                }
            ]))
        }
    }
    private func launch(_ ball: SKSpriteNode, angle: CGFloat) {
        ball.physicsBody?.velocity = CGVector(dx: cos(angle)*ballSpeed, dy: sin(angle)*ballSpeed)
    }
    // Portal volley effect: place two glowing "warp rings" inside the grid.
    // Any ball that passes through the entry ring teleports to the exit ring.
    // Visual-only approach — no physics body needed, we do position checks in update().
    private func activatePortalVolley() {
        // Collect all occupied positions (blocks + pickups currently on the board)
        var occupied = Set<String>()
        enumerateChildNodes(withName: "//*") { node, _ in
            guard let body = node.physicsBody else { return }
            let cat = body.categoryBitMask
            guard cat == Mask.block || cat == Mask.pickup else { return }
            // Round to nearest cell centre so float-animation offsets don't matter
            let col = Int(round((node.position.x - self.gridOrigin.x - self.gap - self.cell/2) / self.step))
            let row = Int(round((self.gridOrigin.y + self.gridH - self.gap - self.cell/2 - node.position.y) / self.step))
            occupied.insert("\(col),\(row)")
        }
        // Find an empty cell in the TOP half (rows 0-3) and BOTTOM half (rows 4-7)
        func emptyCell(inRows range: ClosedRange<Int>) -> CGPoint? {
            var candidates: [CGPoint] = []
            for row in range {
                for col in 0..<self.cols {
                    if !occupied.contains("\(col),\(row)") {
                        candidates.append(self.cellCenter(col: col, row: row))
                    }
                }
            }
            return candidates.randomElement()
        }
        guard let topPos    = emptyCell(inRows: 0...3),
              let bottomPos = emptyCell(inRows: 4...7) else { return }  // no room — skip
        // Entry ring in top half (purple), exit ring in bottom half (teal)
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
            ring.zPosition   = 8; ring.name = "portalRing"
            ring.userData    = NSMutableDictionary()
            ring.userData?["entryY"] = topPos.y
            ring.userData?["exitY"]  = bottomPos.y
            // Inner spinning ring for extra visual pop
            let inner = SKShapeNode(circleOfRadius: cell * 0.22)
            inner.fillColor   = .clear
            inner.strokeColor = color.withAlphaComponent(0.55)
            inner.lineWidth   = 1.2
            inner.run(.repeatForever(.rotate(byAngle: -.pi * 2, duration: 1.2)))
            ring.addChild(inner)
            ring.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 2.0)))
            addChild(ring)
        }
        // Auto-clean after volley ends (12s safety net)
        run(.sequence([.wait(forDuration: 12), .run {
            self.enumerateChildNodes(withName: "portalRing") { n, _ in n.removeFromParent() }
        }]))
    }
    // ─────────────────────────────────────────
    // MARK: update — rover movement + ball logic
    // ─────────────────────────────────────────
    override func update(_ currentTime: TimeInterval) {
        let dt: CGFloat = lastDT == 0 ? 1/60.0
                          : CGFloat(min(currentTime - lastDT, 1/30.0))
        lastDT = currentTime
        // ── Rover movement (always runs, even while flying) ──
        enumerateChildNodes(withName: "block") { node, _ in
            guard node.userData?["rover"] as? Bool == true else { return }
            let stuck = node.userData?["stuck"] as? Bool ?? false
            if stuck { return }
            var dir  = node.userData?["dir"] as? Int ?? 1
            let newX = node.position.x + CGFloat(dir) * self.roverSpeed * dt
            let leftBound  = self.gridOrigin.x + self.gap + self.cell / 2
            let rightBound = self.gridOrigin.x + self.gridW - self.gap - self.cell / 2
            let tolerance  = self.cell * 0.55
            // Check if blocked by adjacent block in movement direction
            var sideBlocked = false
            self.enumerateChildNodes(withName: "block") { other, _ in
                guard other !== node else { return }
                let dx = other.position.x - node.position.x
                let dy = abs(other.position.y - node.position.y)
                if dy < tolerance && abs(dx) < self.cell + self.gap * 1.4 {
                    let sideDir = dx > 0 ? 1 : -1
                    if sideDir == dir { sideBlocked = true }
                }
            }
            let hitWall = (dir == 1 && newX >= rightBound) || (dir == -1 && newX <= leftBound)
            if hitWall || sideBlocked {
                // Try reversing — check if other side is also blocked
                let revDir = -dir
                var revBlocked = false
                let revHitWall = (revDir == 1 && node.position.x >= rightBound - self.cell*0.5)
                              || (revDir == -1 && node.position.x <= leftBound  + self.cell*0.5)
                self.enumerateChildNodes(withName: "block") { other, _ in
                    guard other !== node else { return }
                    let dx = other.position.x - node.position.x
                    let dy = abs(other.position.y - node.position.y)
                    if dy < tolerance && abs(dx) < self.cell + self.gap * 1.4 {
                        let sideDir = dx > 0 ? 1 : -1
                        if sideDir == revDir { revBlocked = true }
                    }
                }
                if revBlocked || revHitWall {
                    node.userData?["stuck"] = true   // wedged — stop until freed
                } else {
                    dir = revDir
                    node.userData?["dir"] = dir
                    node.position.x += CGFloat(dir) * self.roverSpeed * dt
                }
            } else {
                node.position.x = newX
            }
        }
        // ── Ball update ──────────────────────
        guard flying else { return }
        var toProcess: [(SKSpriteNode, SKPhysicsBody)] = []
        enumerateChildNodes(withName: "ball") { node, _ in
            guard let sp = node as? SKSpriteNode,
                  let bd = sp.physicsBody, bd.isDynamic else { return }
            toProcess.append((sp, bd))
        }
        for (sp, body) in toProcess {
            let v   = body.velocity
            let oid = ObjectIdentifier(sp)
            // Track if ball has risen above shooter row
            if sp.position.y > shootY + cell { ballsRisen.insert(oid) }
            // Landing: ball has risen and returned to shooter row moving downward
            if ballsRisen.contains(oid), sp.position.y <= shootY, v.dy <= 0 {
                ballsRisen.remove(oid)
                ballLanded(sp)
                continue
            }
            // Portal warp check — if a ring exists, warp ball at the entry band
            if !children.filter({ $0.name == "portalRing" }).isEmpty {
                enumerateChildNodes(withName: "portalRing") { ringNode, _ in
                    guard let ring = ringNode as? SKShapeNode,
                          let eY   = ring.userData?["entryY"] as? CGFloat,
                          let xY   = ring.userData?["exitY"]  as? CGFloat else { return }
                    // If ball is near entry Y and moving upward, warp it to exit Y
                    if abs(sp.position.y - eY) < self.cell * 0.4 && body.velocity.dy > 0 {
                        sp.position.y = xY
                        // Small flash
                        sp.run(.sequence([.scale(to: 1.5, duration: 0.05), .scale(to: 1.0, duration: 0.08)]))
                    }
                }
            }
            // ── Minimum vertical component ──────────────────────────────
            // Enforce |vy| >= minVY every frame. Makes it physically impossible
            // for the ball to settle into a horizontal bounce loop.
            let minVY: CGFloat = ballSpeed * 0.18
            var vx = v.dx
            var vy = v.dy
            if abs(vy) < minVY {
                // Point away from whichever wall it's closest to vertically
                let midY = shootY + (gridOrigin.y + gridH - shootY) / 2
                vy = sp.position.y > midY ? -minVY : minVY
            }
            // ── Constant speed normaliser ────────────────────────────────────
            let spd = hypot(vx, vy)
            if spd > 1 {
                body.velocity = CGVector(dx: vx/spd*ballSpeed, dy: vy/spd*ballSpeed)
            }
        }
    }
    // ─────────────────────────────────────────
    // MARK: Contacts
    // ─────────────────────────────────────────
    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask
        let pair = a | b
        // Ball ↔ Block
        if pair == Mask.ball | Mask.block {
            let blk = (a == Mask.block ? contact.bodyA : contact.bodyB).node
            if let blk { hitBlock(blk) }
        }
        // Ball ↔ Pickup
        if pair == Mask.ball | Mask.pickup {
            let pickupNode = (a == Mask.pickup ? contact.bodyA : contact.bodyB).node
            if let pickupNode { collectPickup(pickupNode) }
        }
    }
    // ─────────────────────────────────────────
    // MARK: Block hit
    // ─────────────────────────────────────────
    private func hitBlock(_ node: SKNode) {
        guard let lbl  = node.childNode(withName: "hp") as? SKLabelNode,
              let text = lbl.text, var hp = Int(text) else { return }
        hp -= 1
        if hp <= 0 {
            node.physicsBody = nil
            let isBomb = node.userData?["bomb"] as? Bool == true
            if isBomb {
                explode(at: node.position)
                hapticHeavy.impactOccurred(intensity: 1.0)   // big boom
            } else {
                hapticRigid.impactOccurred(intensity: 0.85)   // satisfying block pop
            }
            unstickRoversNear(pos: node.position)
            node.run(.sequence([
                .group([
                    .scale(to: isBomb ? 1.5 : 1.2, duration: 0.07),
                    .fadeOut(withDuration: 0.09)
                ]),
                .removeFromParent()
            ]))
        } else {
            lbl.text = "\(hp)"
            // Haptic intensity scales with how hurt the block is
            let ratio = CGFloat(hp) / CGFloat(max(ballCount, 1))
            if ratio < 0.5 {
                hapticMedium.impactOccurred(intensity: 0.9)   // nearly dead — satisfying thud
            } else {
                hapticLight.impactOccurred(intensity: 0.7)    // regular hit — soft tick
            }
            if let sprite = node.childNode(withName: "blockSprite") as? SKSpriteNode {
                sprite.run(.colorize(with: blockFill(hp: hp), colorBlendFactor: 1, duration: 0.15))
            }
            node.run(.sequence([.scale(to: 0.88, duration: 0.04), .scale(to: 1.00, duration: 0.08)]))
        }
    }
    // ─────────────────────────────────────────
    // MARK: Rover un-stick
    // ─────────────────────────────────────────
    private func unstickRoversNear(pos: CGPoint) {
        enumerateChildNodes(withName: "block") { node, _ in
            guard node.userData?["rover"]  as? Bool == true,
                  node.userData?["stuck"]  as? Bool == true else { return }
            let dist = hypot(node.position.x - pos.x, node.position.y - pos.y)
            if dist < self.cell * 1.8 {
                node.userData?["stuck"] = false
                // Move away from the destroyed block
                node.userData?["dir"] = pos.x > node.position.x ? -1 : 1
            }
        }
    }
    // ─────────────────────────────────────────
    // MARK: Bomb explosion
    // ─────────────────────────────────────────
    private func explode(at pos: CGPoint) {
        let ring = SKShapeNode(circleOfRadius: 4)
        ring.fillColor   = .clear
        ring.strokeColor = UIColor(red: 1.0, green: 0.55, blue: 0.2, alpha: 0.9)
        ring.lineWidth   = 3; ring.position = pos; ring.zPosition = 8
        addChild(ring)
        ring.run(.sequence([
            .group([
                .scale(to: (cell * 2.8) / 4, duration: 0.35),
                .sequence([.wait(forDuration: 0.15), .fadeOut(withDuration: 0.20)])
            ]),
            .removeFromParent()
        ]))
        for _ in 0..<10 {
            let spark = SKShapeNode(circleOfRadius: 3)
            spark.fillColor   = UIColor(red: 1.0, green: CGFloat.random(in: 0.4...0.9), blue: 0.1, alpha: 1)
            spark.strokeColor = .clear
            spark.position    = pos; spark.zPosition = 8
            addChild(spark)
            let dx = CGFloat.random(in: -60...60)
            let dy = CGFloat.random(in: -60...60)
            spark.run(.sequence([
                .group([.moveBy(x: dx, y: dy, duration: 0.4), .fadeOut(withDuration: 0.4)]),
                .removeFromParent()
            ]))
        }
        let blastR = cell * 1.6
        enumerateChildNodes(withName: "//*") { node, _ in
            guard node.name == "block",
                  let body = node.physicsBody,
                  body.categoryBitMask == Mask.block else { return }
            let dist = hypot(node.position.x - pos.x, node.position.y - pos.y)
            if dist < blastR && dist > 1 { self.hitBlock(node) }
        }
    }
    // ─────────────────────────────────────────
    // MARK: Pickup collected
    // ─────────────────────────────────────────
    private func collectPickup(_ node: SKNode) {
        node.physicsBody = nil
        let name = node.name ?? ""
        node.removeFromParent()
        if name == "pickup_ammo" {
            ballCount += 1
            refreshHUD()
            hapticMedium.impactOccurred(intensity: 1.0)   // rewarding pickup pop
            floatLabel("+1", at: node.position, color: UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 1))
        } else if name == "pickup_portal" {
            portalCharges += 1
            refreshHUD()
            hapticHeavy.impactOccurred(intensity: 0.75)   // rare pickup — deeper feel
            floatLabel("⬡ portal!", at: node.position, color: UIColor(red: 0.72, green: 0.50, blue: 1.0, alpha: 1))
        }
    }
    private func floatLabel(_ text: String, at pos: CGPoint, color: UIColor) {
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text = text; lbl.fontSize = 18; lbl.fontColor = color
        lbl.position = pos; lbl.zPosition = 12
        addChild(lbl)
        lbl.run(.sequence([
            .group([
                .moveBy(x: 0, y: 34, duration: 0.55),
                .sequence([.wait(forDuration: 0.25), .fadeOut(withDuration: 0.30)])
            ]),
            .removeFromParent()
        ]))
    }
    // ─────────────────────────────────────────
    // MARK: Ball landed
    // ─────────────────────────────────────────
    private func ballLanded(_ ball: SKSpriteNode) {
        if firstLandX == nil {
            let lo = gridOrigin.x + ballR + gap
            let hi = gridOrigin.x + gridW - ballR - gap
            firstLandX = Swift.min(Swift.max(ball.position.x, lo), hi)
            showNextMarker(x: firstLandX!)
        }
        ball.physicsBody?.velocity = .zero
        ball.physicsBody = nil
        ball.run(.sequence([.fadeOut(withDuration: 0.10), .removeFromParent()]))
        volleyLanded += 1
        if volleyLanded >= volleyTotal { endVolley() }
    }
    private func showNextMarker(x: CGFloat) {
        nextMarker?.removeFromParent()
        let dot = SKShapeNode(circleOfRadius: ballR * 0.7)
        dot.fillColor   = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.25)
        dot.strokeColor = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.65)
        dot.lineWidth   = 1.5
        dot.position    = CGPoint(x: x, y: shootY)
        dot.zPosition   = 4; dot.name = "ui"
        addChild(dot)
        nextMarker = dot
    }
    // ─────────────────────────────────────────
    // MARK: End volley
    // ─────────────────────────────────────────
    private func endVolley() {
        if let lx = firstLandX { shootX = lx }
        firstLandX = nil
        flying     = false
        ballsRisen.removeAll()
        // Clean up any leftover portal rings
        enumerateChildNodes(withName: "portalRing") { n, _ in n.removeFromParent() }
        nextMarker?.removeFromParent(); nextMarker = nil
        turnNumber += 1
        refreshHUD()
        if let panel = children.first(where: {
            $0.name == "ui" && ($0 as? SKShapeNode)?.path != nil
        }) as? SKShapeNode {
            panel.run(.sequence([
                .fadeAlpha(to: 0.12, duration: 0.08),
                .fadeAlpha(to: 0.03, duration: 0.25)
            ]))
        }
        placeShooterBall()
        advanceBoard()
    }
    // ─────────────────────────────────────────
    // MARK: Advance board
    // ─────────────────────────────────────────
    private func advanceBoard() {
        enumerateChildNodes(withName: "//*") { node, _ in
            guard let body = node.physicsBody else { return }
            let cat = body.categoryBitMask
            // Move both blocks and pickups
            guard cat == Mask.block || cat == Mask.pickup else { return }
            let moveDown = SKAction.moveBy(x: 0, y: -self.step, duration: 0.30)
            moveDown.timingMode = .easeInEaseOut
            let snapped = (node.position.y / self.step).rounded() * self.step
            let nextY   = snapped - self.step
            if nextY <= self.shootY + self.cell / 2 {
                node.physicsBody = nil
                node.run(.sequence([moveDown, .fadeOut(withDuration: 0.15), .removeFromParent()]))
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
// ─────────────────────────────────────────
// MARK: CGPath polygon helper
// ─────────────────────────────────────────
private extension CGPath {
    static func polygon(points: [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        guard let first = points.first else { return path }
        path.move(to: first)
        for pt in points.dropFirst() { path.addLine(to: pt) }
        path.closeSubpath()
        return path
    }
}


