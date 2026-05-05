//
//  GameScene.swift
//  challenge2test
//
//  Created by Edward Geraldo Kristian on 30/04/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let ball: UInt32 = 0b1       // 1
        static let block: UInt32 = 0b10     // 2
        static let border: UInt32 = 0b100   // 4
        static let ground: UInt32 = 0b1000  // 8
        static let ammo: UInt32 = 0b10000   // 16
    }
    
    // --- Variables ---
    var totalBalls = 3
    let columns = 7
    let rows = 9
    var isBallInPlay = false
    var playerBall: SKSpriteNode!
    var aimingLine: SKShapeNode?
    var ballStartPos: CGPoint!
    var isAiming = false
    
    override func didMove(to view: SKView) {
        // 1. The Zen Stage
        self.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.93, alpha: 1.0)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) // No falling anxiety
        self.physicsWorld.contactDelegate = self
        
        ballStartPos = CGPoint(x: self.frame.midX, y: self.frame.minY + 150)
        
        // --- 1. Create the Bouncy Walls (Left, Top, Right) ---
        let wallPath = CGMutablePath()
        wallPath.move(to: CGPoint(x: self.frame.minX, y: self.frame.minY))
        wallPath.addLine(to: CGPoint(x: self.frame.minX, y: self.frame.maxY))
        wallPath.addLine(to: CGPoint(x: self.frame.maxX, y: self.frame.maxY))
        wallPath.addLine(to: CGPoint(x: self.frame.maxX, y: self.frame.minY))
        
        let wallsNode = SKNode()
        wallsNode.physicsBody = SKPhysicsBody(edgeChainFrom: wallPath)
        wallsNode.physicsBody?.friction = 0.0
        wallsNode.physicsBody?.restitution = 1.0
        wallsNode.physicsBody?.categoryBitMask = PhysicsCategory.border
        self.addChild(wallsNode)
        
        // --- 2. Create the Ground Sensor ---
        let groundY = ballStartPos.y - 15 // Placed slightly below the ball
        let groundNode = SKNode()
        groundNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: self.frame.minX, y: groundY),
                                               to: CGPoint(x: self.frame.maxX, y: groundY))
        groundNode.physicsBody?.friction = 0.0
        groundNode.physicsBody?.restitution = 0.0 // No bounce on the ground
        groundNode.physicsBody?.categoryBitMask = PhysicsCategory.ground
        self.addChild(groundNode)
        
        // 3. Spawn the initial ball
        spawnPlayerBall()
        
        // 4. Spawn the first row of blocks
        setupInitialBoard()
        
        // 5. Setup the Drag Gesture (The Aiming Mechanic)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    func setupInitialBoard() {
        let blockWidth = (self.frame.width - (10 * 8)) / 7 // 7 columns, 8 spaces
        let rowHeight = blockWidth + 10 // Height + spacing
        
        // Top of the screen, moving downwards
        let topY = self.frame.maxY - 100
        
        // Row 1 is clear (index 0). We spawn rows 2, 3, and 4 (indexes 1, 2, 3).
        for row in 1...3 {
            let currentY = topY - (CGFloat(row) * rowHeight)
            spawnRow(atYPosition: currentY)
        }
    }
    
    // --- Helper Methods ---
    
    func spawnPlayerBall() {
        // Create a soft, rounded ball (We use a built-in shape for the draft)
        playerBall = SKSpriteNode(color: UIColor(red: 0.6, green: 0.7, blue: 0.8, alpha: 1.0), size: CGSize(width: 20, height: 20))
        
        // Make it perfectly round (if it were an image, it would be a circle)
        // For the draft, a rounded square works, but let's give it circle physics
        playerBall.position = ballStartPos
        
        let body = SKPhysicsBody(circleOfRadius: 10)
        body.friction = 0
        body.linearDamping = 0     // No air resistance slowing it down
        body.restitution = 1.0     // Perfect bounce
        body.allowsRotation = false
        
        // 1. Who am I?
        body.categoryBitMask = PhysicsCategory.ball
        // 2. Who do I bounce off of?
        body.collisionBitMask = PhysicsCategory.border | PhysicsCategory.block
        // 3. Who should I notify you about when I touch them?
        body.contactTestBitMask = PhysicsCategory.block | PhysicsCategory.ground
        
        playerBall.physicsBody = body
        self.addChild(playerBall)
    }
    
    // --- The Core Mechanic: Aiming and Shooting ---
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        // We only want to aim if the ball is resting at the start position
        // (You can change this later if you want rapid-fire)
        guard !isBallInPlay else { return }
        
        let translation = gesture.translation(in: self.view)
        
        // We use "Sling-shot" logic: Dragging DOWN aims UP.
        // We flip the Y translation because screen coordinates (UIKit)
        // are opposite to game coordinates (SpriteKit) on the Y axis.
        let dx = -translation.x
        let dy = translation.y
        
        // Calculate the angle using trigonometry
        let angle = atan2(dy, dx)
        
        switch gesture.state {
        case .began:
            isAiming = true
            drawAimingLine(angle: angle)
        case .changed:
            if isAiming {
                updateAimingLine(angle: angle)
            }
        case .ended, .cancelled:
            if isAiming {
                isAiming = false
                removeAimingLine()
                launchBall(angle: angle)
                // LOCK THE GAME: The ball is now flying
                isBallInPlay = true
            }
        default:
            break
        }
    }
    
    // --- Visual Feedback (The "Mental Device") ---
    
    func drawAimingLine(angle: CGFloat) {
        aimingLine = SKShapeNode()
        
        // Use a soft, semi-transparent color for the Zen aesthetic
        aimingLine?.strokeColor = UIColor.lightGray.withAlphaComponent(0.8)
        
        // We make it slightly thicker so it feels soft, not sharp
        aimingLine?.lineWidth = 4.0
        
        // Add it to the scene
        self.addChild(aimingLine!)
        
        // Draw the initial path
        updateAimingLine(angle: angle)
    }
    
    func updateAimingLine(angle: CGFloat) {
        guard let line = aimingLine else { return }
        
        let path = CGMutablePath()
        // 1. Get the EXACT current position of the ball
        let currentPos = playerBall.position
        
        // 2. Draw the line starting from the ball
        path.move(to: currentPos)
        
        let length: CGFloat = 1000
        let endX = currentPos.x + (cos(angle) * length)
        let endY = currentPos.y + (sin(angle) * length)
        
        path.addLine(to: CGPoint(x: endX, y: endY))
        
        let pattern: [CGFloat] = [15.0, 15.0]
        let dashedPath = path.copy(dashingWithPhase: 0, lengths: pattern)
        line.path = dashedPath
    }
    
    func removeAimingLine() {
        aimingLine?.removeFromParent()
        aimingLine = nil
    }
    
    // --- The Physics Action ---
    
    func launchBall(angle: CGFloat) {
        let speed: CGFloat = 800 // The constant speed of the ball
        
        // Apply velocity based on the angle
        let velocityX = cos(angle) * speed
        let velocityY = sin(angle) * speed
        
        playerBall.physicsBody?.velocity = CGVector(dx: velocityX, dy: velocityY)
        
        // Optional: Spawn a new ball immediately at the start position
        // so the player can shoot again while the first is bouncing
        // spawnPlayerBall()
    }
    
    func spawnRow(atYPosition yPos: CGFloat) {
        let spacing: CGFloat = 10
        // Calculate width to perfectly fit 7 columns across the screen
        let availableWidth = self.frame.width - (spacing * CGFloat(columns + 1))
        let blockWidth = availableWidth / CGFloat(columns)
        let blockHeight: CGFloat = blockWidth // Keep them square
        
        // Create an array of column indexes [0, 1, 2, 3, 4, 5, 6] and shuffle them
        var availableColumns = Array(0..<columns)
        availableColumns.shuffle()
        
        // Pick 2 to 4 columns to be Blocks
        let numBlocks = Int.random(in: 2...4)
        let blockColumns = Array(availableColumns.prefix(numBlocks))
        
        // The remaining columns are empty gaps. We will pick one to spawn Ammo.
        let emptyColumns = Array(availableColumns.suffix(columns - numBlocks))
        let ammoColumn = emptyColumns.randomElement()
        
        // Calculate starting X so the row is perfectly centered
        let startX = self.frame.minX + spacing + (blockWidth / 2)
        
        for col in 0..<columns {
            let xPos = startX + CGFloat(col) * (blockWidth + spacing)
            let spawnPos = CGPoint(x: xPos, y: yPos)
            
            if blockColumns.contains(col) {
                // --- SPAWN BLOCK ---
                let block = SKSpriteNode(color: UIColor(red: 0.8, green: 0.85, blue: 0.8, alpha: 1.0), size: CGSize(width: blockWidth, height: blockHeight))
                block.position = spawnPos
                
                let body = SKPhysicsBody(rectangleOf: block.size)
                body.isDynamic = false
                body.categoryBitMask = PhysicsCategory.block
                block.physicsBody = body
                
                let hp = calculateBlockHP()
                
                let numberLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
                numberLabel.name = "blockNumber"
                numberLabel.text = "\(hp)"
                numberLabel.fontSize = blockWidth * 0.4
                numberLabel.fontColor = .darkGray
                numberLabel.verticalAlignmentMode = .center
                
                block.addChild(numberLabel)
                
                // Soft spawn animation
                block.alpha = 0
                block.setScale(0.1)
                self.addChild(block)
                block.run(SKAction.group([SKAction.fadeIn(withDuration: 0.6), SKAction.scale(to: 1.0, duration: 0.6)]))
                
            } else if col == ammoColumn {
                // --- SPAWN AMMO IN A GAP ---
                // Create a small visual indicator for the extra ball
                let ammoNode = SKSpriteNode(color: UIColor(red: 0.6, green: 0.7, blue: 0.8, alpha: 1.0), size: CGSize(width: 15, height: 15))
                ammoNode.position = spawnPos
                ammoNode.name = "ammoDrop"
                
                // Circular physics body to detect ball collision
                let ammoBody = SKPhysicsBody(circleOfRadius: 7.5)
                ammoBody.isDynamic = false
                ammoBody.categoryBitMask = PhysicsCategory.ammo
                ammoNode.physicsBody = ammoBody
                
                // Gentle floating animation to make it look collectible
                let hoverUp = SKAction.moveBy(x: 0, y: 5, duration: 0.8)
                let hoverDown = SKAction.moveBy(x: 0, y: -5, duration: 0.8)
                hoverUp.timingMode = .easeInEaseOut
                hoverDown.timingMode = .easeInEaseOut
                ammoNode.run(SKAction.repeatForever(SKAction.sequence([hoverUp, hoverDown])))
                
                self.addChild(ammoNode)
            }
        }
    }
    
    func spawnBlockRow() {
        let blockWidth: CGFloat = 60
        let blockHeight: CGFloat = 60
        let spacing: CGFloat = 10
        
        let totalWidth = self.frame.width
        let columns = Int(totalWidth / (blockWidth + spacing))
        
        let startX = self.frame.minX + (totalWidth - CGFloat(columns) * (blockWidth + spacing)) / 2 + (blockWidth / 2)
        let startY = self.frame.maxY - 100
        
        // Safeguard: Track if we spawned at least one block this row
        var spawnedAtLeastOne = false
        
        for i in 0..<columns {
            
            // Zen Design: Give a 40% chance to SKIP this block to create a gap
            let shouldSkip = Int.random(in: 1...100) <= 40
            
            // If the randomizer says skip, AND we aren't on the very last column
            // with an empty row, we skip to the next loop.
            if shouldSkip && !(i == columns - 1 && !spawnedAtLeastOne) {
                continue // Skips creating a block here
            }
            
            spawnedAtLeastOne = true // We successfully made a block!
            
            // Create the Block
            let block = SKSpriteNode(color: UIColor(red: 0.8, green: 0.85, blue: 0.8, alpha: 1.0), size: CGSize(width: blockWidth, height: blockHeight))
            block.position = CGPoint(x: startX + CGFloat(i) * (blockWidth + spacing), y: startY)
            
            let body = SKPhysicsBody(rectangleOf: block.size)
            body.isDynamic = false
            body.categoryBitMask = PhysicsCategory.block
            block.physicsBody = body
            
            // Add a Number Label
            let numberLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            numberLabel.name = "blockNumber"
            numberLabel.text = "\(Int.random(in: 1...6))" // Random number 1-6
            numberLabel.fontSize = 24
            numberLabel.fontColor = .darkGray
            numberLabel.verticalAlignmentMode = .center
            
            block.addChild(numberLabel)
            self.addChild(block)
        }
    }
    // --- Progression Loop ---
    
    func advanceTurn() {
        let downwardDistance: CGFloat = 70.0 // Block height (60) + spacing (10)
        
        // 1. Find all blocks on the screen and move them down
        self.enumerateChildNodes(withName: "//*") { node, _ in
            // Check if the node is a block
            if node.physicsBody?.categoryBitMask == PhysicsCategory.block {
                
                // Create a smooth, relaxing downward animation
                let moveDown = SKAction.moveBy(x: 0, y: -downwardDistance, duration: 0.4)
                moveDown.timingMode = .easeInEaseOut // Starts slow, ends slow
                
                // Zen Rule: No Game Over. If a block gets too close to the bottom,
                // we peacefully fade it out and remove it instead of killing the player.
                if node.position.y - downwardDistance <= self.ballStartPos.y + 50 {
                    let fade = SKAction.fadeOut(withDuration: 0.3)
                    let remove = SKAction.removeFromParent()
                    node.run(SKAction.sequence([moveDown, fade, remove]))
                } else {
                    node.run(moveDown)
                }
            }
        }
        
        // 2. Spawn a brand new row at the top
        spawnRow(atYPosition: self.frame.maxY - 100)
    }
    
    func calculateBlockHP() -> Int {
        let roll = Int.random(in: 1...100)
        let variance = Int.random(in: -2...2) // Range of -2 to +2
        var baseHP: Double = 0
        
        if roll <= 60 {
            // 60% chance: Half of current balls
            baseHP = Double(totalBalls) / 2.0
        } else if roll <= 90 {
            // 30% chance: Equal to current balls
            baseHP = Double(totalBalls)
        } else {
            // 10% chance: 150% of current balls
            baseHP = Double(totalBalls) * 1.5
        }
        
        // Calculate final HP and ensure it never drops below 1
        let finalHP = Int(round(baseHP)) + variance
        return max(1, finalHP)
    }
    
    // --- Collision Handling ---
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Check if the collision is between the Ball and a Block
        if firstBody.categoryBitMask == PhysicsCategory.ball && secondBody.categoryBitMask == PhysicsCategory.block {
            if let blockNode = secondBody.node as? SKSpriteNode {
                blockHit(block: blockNode)
            }
        }
        
        // Check Ground Hit
        if firstBody.categoryBitMask == PhysicsCategory.ball && secondBody.categoryBitMask == PhysicsCategory.ground {
            ballHitGround()
        }
        
        // Check Ammo Hit
        if firstBody.categoryBitMask == PhysicsCategory.ball && secondBody.categoryBitMask == PhysicsCategory.ammo {
            if let ammoNode = secondBody.node {
                ammoNode.removeFromParent() // Remove it from the screen
                totalBalls += 1             // Increase player's ammo count
            }
        }
    }
    
    // --- Extracted Helper Functions ---
    
    func ballHitGround() {
        guard isBallInPlay else { return }
        isBallInPlay = false // UNLOCK THE GAME
        
        // Stop the ball and reset its Y position
        playerBall.physicsBody?.velocity = .zero
        playerBall.position.y = ballStartPos.y
        
        // Trigger the Zen breathing loop
        advanceTurn()
    }
    
    func blockHit(block: SKSpriteNode) {
        if let label = block.childNode(withName: "blockNumber") as? SKLabelNode,
           let currentText = label.text,
           var number = Int(currentText) {
            
            number -= 1
            
            if number <= 0 {
                block.removeFromParent()
            } else {
                label.text = "\(number)"
                let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
                let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
                block.run(SKAction.sequence([scaleDown, scaleUp]))
            }
        }
    }
}
