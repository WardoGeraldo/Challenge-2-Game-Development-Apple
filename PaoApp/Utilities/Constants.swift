//
//  Constants.swift
//  PaoApp
//

import CoreGraphics
import Foundation

// MARK: Random Statistics
// Deck size
let randomShuffledDistributionLowestValue = 1
let randomShuffledDistributionHighestValue = 10 //Flexible can be changed later

// Block Type Probabilities
let randomBlockType1Probability: Double = 0.60 //60%
let randomBlockType2Probability: Double = 0.90 //30%
let randomBlockType3Probability: Double = 1.0  //10%

// HP Multiplier
let randomBlockType1Multiplier: Double = 0.50
let randomBlockType2Multiplier: Double = 1.0
let randomBlockType3Multiplier: Double = 1.5

// Random Variance Range -2 to +2
let randomMinVariance = -2
let randomMaxVariance = 2

enum GameConstants {
    // Grid layout
    static let cols:      Int     = 7
    static let blockRows: Int     = 9
    static let gap:       CGFloat = 6

    // Ball
    static let ballRadius: CGFloat      = 16
    static let ballSpeed:  CGFloat      = 480
    static let shootGap:   TimeInterval = 0.13

    // Rover
    static let roverSpeed: CGFloat = 30

    // Volley
    // Tiny downward acceleration applied every frame (pts/s²).
    // A 70° shot curves <3° over its full flight — invisible.
    // A horizontal stuck ball drifts down ~12° after 3 s and lands naturally.
    static let gravityAccel: CGFloat = 30

    // Initial values
    static let initialBallCount = 3

    // Typography
    static let fontName = "MelonPop"
}
