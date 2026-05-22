//
//  ScoreManager.swift
//  PaoApp
//

import Foundation

class ScoreManager {
    static let shared = ScoreManager()

    private let highScoreKey = "highScore"

    // Current game score — resets each new game
    private(set) var currentLevel: Int = 0
    private(set) var currentScore: Int = 0

    // All-time best, persisted across sessions
    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: highScoreKey) }
    }

    private init() {}

    // Points earned per block kill based on its max HP
    func points(forMaxHP hp: Int) -> Int {
        return hp * 10
    }

    // Call this when a block dies
    func addPoints(_ points: Int) {
        currentScore += points
    }

    // Call on game over — saves highscore if beaten, returns true if new record
    func submit() -> Bool {
        if currentScore > highScore {
            highScore = currentScore
            return true
        }
        return false
    }

    func addLevel(_ level: Int = 1) {
        currentLevel += level
    }

    // Call at the start of each new game
    func reset() {
        currentScore = 0
    }
}
