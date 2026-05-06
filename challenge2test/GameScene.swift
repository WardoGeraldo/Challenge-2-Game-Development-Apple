//
//  GameScene.swift
//  challenge2test
//

import SpriteKit

// MARK: - Physics
private enum Mask {
    static let ball:  UInt32 = 1
    static let block: UInt32 = 2
    static let wall:  UInt32 = 4
    static let ammo:  UInt32 = 16
}

// MARK: - Block type
private enum BlockType {
    case normal                      // plain square — always available
    case triangle(flipped: Bool)     // triangle — unlocks turn 5
    case bomb                        // explosion on death — unlocks turn 10
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
    private let ballSpeed: CGFloat      = 580
    private let shootGap:  TimeInterval = 0.13

    // ── State ─────────────────────────────────
    private var ballCount  = 3
    private var turnNumber = 0       // used for progressive unlocks + HP scaling
    private var flying     = false
    private var aiming     = false

    private var volleyTotal:  Int      = 0
    private var volleyLanded: Int      = 0
    private var firstLandX:   CGFloat? = nil
    private var shotAngle:    CGFloat  = .pi / 2
    private var ballsRisen:   Set<ObjectIdentifier> = []

    private var stuckTick:  TimeInterval = 0
    private let stuckLimit: TimeInterval = 2.5

    // ── Geometry ──────────────────────────────
    private var gridOrigin = CGPoint.zero
    private var gridW: CGFloat = 0
    private var gridH: CGFloat = 0
    private var shootY: CGFloat = 0
    private var shootX: CGFloat = 0

    // ── Nodes ─────────────────────────────────
    private var shooterBall: SKSpriteNode!
    private var aimLine:     SKShapeNode?
    private var countLabel:  SKLabelNode!
    private var nextMarker:  SKShapeNode?
    private var turnLabel:   SKLabelNode!

    // ─────────────────────────────────────────
    // MARK: didMove
    // ─────────────────────────────────────────
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.16, alpha: 1)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        physicsWorld.speed = 1.0

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
        // Outer panel
        let panel = SKShapeNode(
            rect: CGRect(x: gridOrigin.x, y: gridOrigin.y,
                         width: gridW, height: gridH), cornerRadius: 14)
        panel.fillColor   = UIColor(white: 1, alpha: 0.03)
        panel.strokeColor = UIColor(white: 1, alpha: 0.10)
        panel.lineWidth   = 1.5; panel.zPosition = 0; panel.name = "ui"
        addChild(panel)

        // Ghost cells — block zone
        for r in 0..<blockRows {
            for c in 0..<cols { ghostCell(col: c, row: r, shooter: false) }
        }
        // Shooter row — blue tint
        for c in 0..<cols { ghostCell(col: c, row: blockRows, shooter: true) }

        // Divider
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
        // Ball icon
        let iconX = gridOrigin.x + gap + ballR + 2
        let icon  = SKShapeNode(circleOfRadius: ballR)
        icon.fillColor   = ballFill
        icon.strokeColor = .clear
        icon.position    = CGPoint(x: iconX, y: shootY)
        icon.zPosition   = 10; icon.name = "ui"
        addChild(icon)

        // Count label
        countLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countLabel.fontSize                = 16
        countLabel.fontColor               = UIColor(white: 0.9, alpha: 1)
        countLabel.text                    = "×\(ballCount)"
        countLabel.horizontalAlignmentMode = .left
        countLabel.verticalAlignmentMode   = .center
        countLabel.position  = CGPoint(x: iconX + ballR + 6, y: shootY)
        countLabel.zPosition = 10
        addChild(countLabel)

        // Turn label (top-right of grid)
        turnLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        turnLabel.fontSize                = 13
        turnLabel.fontColor               = UIColor(white: 0.5, alpha: 1)
        turnLabel.text                    = "TURN 1"
        turnLabel.horizontalAlignmentMode = .right
        turnLabel.verticalAlignmentMode   = .center
        turnLabel.position  = CGPoint(x: gridOrigin.x + gridW - 6,
                                      y: shootY)
        turnLabel.zPosition = 10
        addChild(turnLabel)
    }

    private var ballFill: UIColor {
        UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 1)
    }

    private func refreshHUD() {
        countLabel.text = "×\(ballCount)"
        countLabel.run(.sequence([.scale(to: 1.5, duration: 0.07),
                                  .scale(to: 1.0, duration: 0.10)]))
        turnLabel.text = "TURN \(turnNumber + 1)"
    }

    // ─────────────────────────────────────────
    // MARK: Shooter ball  — circle shape
    // ─────────────────────────────────────────
    private func placeShooterBall() {
        shooterBall?.removeFromParent()
        shooterBall          = makeBallNode()
        shooterBall.position = CGPoint(x: shootX, y: shootY)
        addChild(shooterBall)
    }

    private func makeBallNode() -> SKSpriteNode {
        // Draw a crisp circle using a CGPath mask
        let diameter = Int(ballR * 2)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        let img = renderer.image { ctx in
            UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 1).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0,
                                                  width: diameter, height: diameter))
            // Specular highlight
            UIColor(white: 1, alpha: 0.45).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: diameter/4, y: diameter/4,
                                                  width: diameter/3, height: diameter/3))
        }
        let b = SKSpriteNode(texture: SKTexture(image: img),
                             size: CGSize(width: ballR*2, height: ballR*2))
        b.name      = "ball"
        b.zPosition = 7

        let body = SKPhysicsBody(circleOfRadius: ballR)
        body.friction           = 0
        body.linearDamping      = 0
        body.restitution        = 1
        body.allowsRotation     = false
        body.isDynamic          = true
        body.categoryBitMask    = Mask.ball
        body.collisionBitMask   = Mask.wall | Mask.block
        body.contactTestBitMask = Mask.block | Mask.ammo
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

        let shuffled = Array(0..<cols).shuffled()
        let nBlocks  = Int.random(in: 2...4)
        let bCols    = Set(shuffled.prefix(nBlocks))
        let eCols    = shuffled.filter { !bCols.contains($0) }

        // Ammo appears roughly 1 per row, less frequently as game progresses
        let ammoChance = max(25, 55 - turnNumber * 2)  // 55% → 25% over time
        let ammoCol: Int? = Int.random(in: 0...99) < ammoChance ? eCols.randomElement() : nil

        for c in 0..<cols {
            let pos = cellCenter(col: c, row: row)
            if bCols.contains(c) {
                addBlock(at: pos, type: randomBlockType())
            } else if c == ammoCol {
                addAmmo(at: pos)
            }
        }
    }

    // Progressive block type unlock
    private func randomBlockType() -> BlockType {
        let hasBomb     = turnNumber >= 10
        let hasTriangle = turnNumber >= 5

        let roll = Int.random(in: 0...99)
        if hasBomb && roll < 12 {
            return .bomb
        } else if hasTriangle && roll < 30 {
            return .triangle(flipped: Bool.random())
        }
        return .normal
    }

    // ─────────────────────────────────────────
    // MARK: Block builders
    // ─────────────────────────────────────────
    private func addBlock(at pos: CGPoint, type: BlockType) {
        let hp   = blockHP()
        let node = SKNode()
        node.position  = pos
        node.name      = "block"
        node.zPosition = 3

        switch type {
        case .normal:
            buildNormalBlock(node: node, hp: hp)
        case .triangle(let flipped):
            buildTriangleBlock(node: node, hp: hp, flipped: flipped)
        case .bomb:
            buildBombBlock(node: node, hp: hp)
        }

        node.alpha = 0; node.setScale(0.2)
        addChild(node)
        node.run(.group([.fadeIn(withDuration: 0.35),
                         .scale(to: 1.0, duration: 0.35)]))
    }

    private func buildNormalBlock(node: SKNode, hp: Int) {
        let sprite = SKSpriteNode(color: blockFill(hp: hp),
                                  size: CGSize(width: cell, height: cell))
        sprite.name = "blockSprite"

        // Rounded corners via overlay shape
        let corner = SKShapeNode(
            rect: CGRect(x: -cell/2, y: -cell/2, width: cell, height: cell),
            cornerRadius: 7)
        corner.fillColor   = .clear
        corner.strokeColor = UIColor(white: 1, alpha: 0.12)
        corner.lineWidth   = 1; corner.zPosition = 1

        let body = SKPhysicsBody(rectangleOf: CGSize(width: cell, height: cell))
        body.isDynamic = false; body.friction = 0; body.restitution = 1
        body.categoryBitMask = Mask.block; body.collisionBitMask = Mask.ball
        body.contactTestBitMask = Mask.ball
        node.physicsBody = body

        node.addChild(sprite)
        node.addChild(corner)
        node.addChild(hpLabel(hp: hp, fontSize: cell * 0.38))
    }

    private func buildTriangleBlock(node: SKNode, hp: Int, flipped: Bool) {
        // Visual triangle
        let path = CGMutablePath()
        let h    = cell
        if flipped {
            // ◿ — right-angle at bottom-left, angled face top-right
            path.move(to:    CGPoint(x: -h/2,  y: -h/2))
            path.addLine(to: CGPoint(x:  h/2,  y: -h/2))
            path.addLine(to: CGPoint(x:  h/2,  y:  h/2))
        } else {
            // ◺ — right-angle at bottom-right, angled face top-left
            path.move(to:    CGPoint(x: -h/2,  y: -h/2))
            path.addLine(to: CGPoint(x:  h/2,  y: -h/2))
            path.addLine(to: CGPoint(x: -h/2,  y:  h/2))
        }
        path.closeSubpath()

        let shape = SKShapeNode(path: path)
        shape.fillColor   = UIColor(red: 0.85, green: 0.62, blue: 0.20, alpha: 1)
        shape.strokeColor = UIColor(white: 1, alpha: 0.18)
        shape.lineWidth   = 1; shape.name = "blockSprite"

        // Triangle physics — angled face makes ball deflect differently
        var points: [CGPoint] = flipped
            ? [CGPoint(x:-h/2,y:-h/2), CGPoint(x:h/2,y:-h/2), CGPoint(x:h/2,y:h/2)]
            : [CGPoint(x:-h/2,y:-h/2), CGPoint(x:h/2,y:-h/2), CGPoint(x:-h/2,y:h/2)]
        let body = SKPhysicsBody(polygonFrom: CGPath.polygon(points: points))
        body.isDynamic = false; body.friction = 0; body.restitution = 1
        body.categoryBitMask = Mask.block; body.collisionBitMask = Mask.ball
        body.contactTestBitMask = Mask.ball
        node.physicsBody = body

        node.addChild(shape)
        node.addChild(hpLabel(hp: hp, fontSize: cell * 0.30))
    }

    private func buildBombBlock(node: SKNode, hp: Int) {
        let sprite = SKSpriteNode(color: UIColor(red: 0.85, green: 0.22, blue: 0.22, alpha: 1),
                                  size: CGSize(width: cell, height: cell))
        sprite.name = "blockSprite"
        node.userData = NSMutableDictionary()
        node.userData?["bomb"] = true

        // Pulsing glow to signal danger
        let glow = SKShapeNode(
            rect: CGRect(x: -cell/2, y: -cell/2, width: cell, height: cell),
            cornerRadius: 7)
        glow.fillColor   = .clear
        glow.strokeColor = UIColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 0.5)
        glow.lineWidth   = 2; glow.zPosition = 1
        glow.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.15, duration: 0.7),
            .fadeAlpha(to: 0.8,  duration: 0.7)
        ])))

        // Bomb icon (💥 emoji as label)
        let icon = SKLabelNode(text: "💣")
        icon.fontSize              = cell * 0.38
        icon.verticalAlignmentMode = .center
        icon.position              = CGPoint(x: 0, y: cell * 0.08)

        let body = SKPhysicsBody(rectangleOf: CGSize(width: cell, height: cell))
        body.isDynamic = false; body.friction = 0; body.restitution = 1
        body.categoryBitMask = Mask.block; body.collisionBitMask = Mask.ball
        body.contactTestBitMask = Mask.ball
        node.physicsBody = body

        node.addChild(sprite)
        node.addChild(glow)
        node.addChild(icon)
        node.addChild(hpLabel(hp: hp, fontSize: cell * 0.28, offsetY: -cell * 0.24))
    }

    private func hpLabel(hp: Int, fontSize: CGFloat, offsetY: CGFloat = 0) -> SKLabelNode {
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.name                    = "hp"
        lbl.text                    = "\(hp)"
        lbl.fontSize                = fontSize
        lbl.fontColor               = .white
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center
        lbl.position                = CGPoint(x: 0, y: offsetY)
        return lbl
    }

    private func addAmmo(at pos: CGPoint) {
        let r    = ballR * 0.85
        let node = SKShapeNode(circleOfRadius: r)
        node.fillColor   = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.9)
        node.strokeColor = UIColor(white: 1, alpha: 0.6)
        node.lineWidth   = 1.5
        node.position    = pos; node.name = "ammo"; node.zPosition = 3

        // Inner sparkle
        let inner = SKShapeNode(circleOfRadius: r * 0.45)
        inner.fillColor   = UIColor(white: 1, alpha: 0.6)
        inner.strokeColor = .clear
        node.addChild(inner)

        let body = SKPhysicsBody(circleOfRadius: r)
        body.isDynamic          = false
        body.categoryBitMask    = Mask.ammo
        body.collisionBitMask   = 0
        body.contactTestBitMask = Mask.ball
        node.physicsBody = body

        node.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 3, duration: 0.6),
            .moveBy(x: 0, y: -3, duration: 0.6)
        ])))
        node.run(.repeatForever(.sequence([
            .scale(to: 1.10, duration: 0.9),
            .scale(to: 0.92, duration: 0.9)
        ])))
        addChild(node)
    }

    // ─────────────────────────────────────────
    // MARK: HP / colour helpers
    // ─────────────────────────────────────────
    private func blockHP() -> Int {
        // HP scales with turn number for progressive difficulty
        let base: Double
        let roll = Int.random(in: 1...100)
        switch roll {
        case ...60: base = Double(ballCount) * 0.5
        case ...90: base = Double(ballCount)
        default:    base = Double(ballCount) * 1.5
        }
        let turn    = Double(turnNumber) * 0.3
        let raw     = Int(round(base + turn)) + Int.random(in: -1...1)
        return max(1, raw)
    }

    private func blockFill(hp: Int) -> UIColor {
        // Maps HP relative to ballCount to a colour: teal → green → amber → red
        let ratio = CGFloat(hp) / CGFloat(max(ballCount, 1))
        switch ratio {
        case ..<0.6:
            // Low HP — teal/green
            return UIColor(red: 0.20, green: 0.72, blue: 0.55, alpha: 1)
        case ..<1.0:
            // Mid HP — amber
            return UIColor(red: 0.85, green: 0.65, blue: 0.15, alpha: 1)
        default:
            // High HP — red/orange
            return UIColor(red: 0.85, green: 0.28, blue: 0.22, alpha: 1)
        }
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
    // MARK: Aim line — dashed with dot at ball
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
        p.addLine(to: CGPoint(x: o.x + cos(angle)*len,
                              y: o.y + sin(angle)*len))
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
        stuckTick    = 0
        ballsRisen.removeAll()

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
        ball.physicsBody?.velocity = CGVector(dx: cos(angle)*ballSpeed,
                                              dy: sin(angle)*ballSpeed)
    }

    // ─────────────────────────────────────────
    // MARK: update
    // ─────────────────────────────────────────
    override func update(_ currentTime: TimeInterval) {
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

            if sp.position.y > shootY + cell { ballsRisen.insert(oid) }

            if ballsRisen.contains(oid), sp.position.y <= shootY, v.dy <= 0 {
                ballsRisen.remove(oid)
                ballLanded(sp)
                continue
            }

            // Stuck watchdog
            if abs(v.dy) < 20 && abs(v.dx) > 30 {
                stuckTick += 1.0/60.0
                if stuckTick >= stuckLimit {
                    stuckTick = 0
                    let sign: CGFloat = v.dy >= 0 ? -1 : 1
                    body.velocity = CGVector(dx: v.dx, dy: sign * ballSpeed * 0.5)
                }
            } else { stuckTick = 0 }

            // Constant speed
            let spd = hypot(v.dx, v.dy)
            if spd > 1 {
                body.velocity = CGVector(dx: v.dx/spd*ballSpeed, dy: v.dy/spd*ballSpeed)
            }
        }
    }

    // ─────────────────────────────────────────
    // MARK: Contacts
    // ─────────────────────────────────────────
    func didBegin(_ contact: SKPhysicsContact) {
        let a    = contact.bodyA.categoryBitMask
        let b    = contact.bodyB.categoryBitMask
        let pair = a | b

        if pair == Mask.ball | Mask.block {
            let blk = (a == Mask.block ? contact.bodyA : contact.bodyB).node
            if let blk { hitBlock(blk) }
        }
        if pair == Mask.ball | Mask.ammo {
            let ammoNode = (a == Mask.ammo ? contact.bodyA : contact.bodyB).node
            if let ammoNode { collectAmmo(ammoNode) }
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
            if isBomb { explode(at: node.position) }
            node.run(.sequence([
                .group([
                    .scale(to: isBomb ? 1.5 : 1.2, duration: 0.07),
                    .fadeOut(withDuration: 0.09)
                ]),
                .removeFromParent()
            ]))
        } else {
            lbl.text = "\(hp)"
            // Update colour
            if let sprite = node.childNode(withName: "blockSprite") as? SKSpriteNode {
                sprite.run(.sequence([
                    .colorize(with: blockFill(hp: hp), colorBlendFactor: 1, duration: 0.15)
                ]))
            }
            node.run(.sequence([.scale(to: 0.88, duration: 0.04),
                                 .scale(to: 1.00, duration: 0.08)]))
        }
    }

    // ─────────────────────────────────────────
    // MARK: Bomb explosion — area damage
    // ─────────────────────────────────────────
    private func explode(at pos: CGPoint) {
        // Visual shockwave
        let ring = SKShapeNode(circleOfRadius: 4)
        ring.fillColor   = .clear
        ring.strokeColor = UIColor(red: 1.0, green: 0.55, blue: 0.2, alpha: 0.9)
        ring.lineWidth   = 3
        ring.position    = pos; ring.zPosition = 8
        addChild(ring)
        ring.run(.sequence([
            .group([
                .scale(to: (cell * 2.8) / 4, duration: 0.35),
                .sequence([.wait(forDuration: 0.15), .fadeOut(withDuration: 0.20)])
            ]),
            .removeFromParent()
        ]))

        // Particle burst
        for _ in 0..<10 {
            let spark = SKShapeNode(circleOfRadius: 3)
            spark.fillColor = UIColor(red: 1.0,
                                      green: CGFloat.random(in: 0.4...0.9),
                                      blue: 0.1, alpha: 1)
            spark.strokeColor = .clear
            spark.position    = pos; spark.zPosition = 8
            addChild(spark)
            let dx = CGFloat.random(in: -60...60)
            let dy = CGFloat.random(in: -60...60)
            spark.run(.sequence([
                .group([
                    .moveBy(x: dx, y: dy, duration: 0.4),
                    .fadeOut(withDuration: 0.4)
                ]),
                .removeFromParent()
            ]))
        }

        // Damage all blocks within ~1.5 cell radius
        let blastR = cell * 1.6
        enumerateChildNodes(withName: "//*") { node, _ in
            guard node.name == "block",
                  let body = node.physicsBody,
                  body.categoryBitMask == Mask.block else { return }
            let dist = hypot(node.position.x - pos.x, node.position.y - pos.y)
            if dist < blastR && dist > 1 {
                self.hitBlock(node)
            }
        }
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
        dot.fillColor   = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.30)
        dot.strokeColor = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 0.70)
        dot.lineWidth   = 1.5
        dot.position    = CGPoint(x: x, y: shootY)
        dot.zPosition   = 4; dot.name = "ui"
        addChild(dot)
        nextMarker = dot
    }

    // ─────────────────────────────────────────
    // MARK: Ammo collected
    // ─────────────────────────────────────────
    private func collectAmmo(_ node: SKNode) {
        node.physicsBody = nil
        node.removeFromParent()
        ballCount += 1
        refreshHUD()

        // Satisfying +1 pop label
        let pop = SKLabelNode(fontNamed: "AvenirNext-Bold")
        pop.text      = "+1"
        pop.fontSize  = 20
        pop.fontColor = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 1)
        pop.position  = node.position; pop.zPosition = 12
        addChild(pop)
        pop.run(.sequence([
            .group([
                .moveBy(x: 0, y: 30, duration: 0.5),
                .sequence([.wait(forDuration: 0.25), .fadeOut(withDuration: 0.25)])
            ]),
            .removeFromParent()
        ]))
    }

    // ─────────────────────────────────────────
    // MARK: End volley
    // ─────────────────────────────────────────
    private func endVolley() {
        if let lx = firstLandX { shootX = lx }
        firstLandX = nil
        flying     = false
        stuckTick  = 0
        ballsRisen.removeAll()

        nextMarker?.removeFromParent()
        nextMarker = nil

        turnNumber += 1
        refreshHUD()

        // Satisfying "turn end" pulse on grid panel
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
            guard cat == Mask.block || cat == Mask.ammo else { return }

            let moveDown = SKAction.moveBy(x: 0, y: -self.step, duration: 0.30)
            moveDown.timingMode = .easeInEaseOut

            let snapped = (node.position.y / self.step).rounded() * self.step
            let nextY   = snapped - self.step

            if nextY <= self.shootY + self.cell / 2 {
                node.physicsBody = nil
                node.run(.sequence([moveDown,
                                    .fadeOut(withDuration: 0.15),
                                    .removeFromParent()]))
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
// MARK: CGPath helper for polygon
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
