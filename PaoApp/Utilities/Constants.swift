//
//  Constants.swift
//  PaoApp
//

import CoreGraphics
import Foundation

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
