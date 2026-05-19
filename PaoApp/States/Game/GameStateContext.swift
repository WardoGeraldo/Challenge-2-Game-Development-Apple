//
//  GameStateContext.swift
//  PaoApp
//
//  Created by Axel on 13/05/26.
//

import CoreGraphics
import Foundation

// States communicate with GameScene through this protocol to stay decoupled.
protocol GameStateContext: AnyObject {

    // MARK: - Read state
    var shooterPosition: CGPoint { get }
    var pendingShotAngle: CGFloat { get set }
    var isVolleyComplete: Bool { get }

    // MARK: - GameStart
    func setupInitialGame()

    // MARK: - GameAiming
    func showAimLine(from origin: CGPoint, angle: CGFloat)
    func hideAimLine()

    // MARK: - GameFlying
    func fireVolley()

    // MARK: - GameTurnEnd
    /// Advances the board one row down. Returns `true` if the game is over.
    func advanceBoard() -> Bool

    // MARK: - GameOver
    func showGameOverScreen()
    func resetGame()
}
