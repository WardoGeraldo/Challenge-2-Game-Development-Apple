//
//  RandomManager.swift
//  PaoApp
//
//  Created by Edward Geraldo Kristian on 11/05/26.
//

import GameplayKit

class RandomManager {
    // 1. Create a shared instance so the entire game uses the same 'deck'
    static let shared = RandomManager() //singleton style
    
    // 2. The 10-card deck (1-10) to prevent unfair streaks
    private let blockTypeDistribution: GKShuffledDistribution
    
    // 3. Regular random for the small -2 to +2 variance
    private let varianceDistribution: GKRandomDistribution
    
    private let dynamicType1Threshold: Int
    private let dynamicType2Threshold: Int
    
    // Private init ensures no one else can accidentally create a second deck
    private init() {
        // Initialize the decks using the global variables from Constant
        blockTypeDistribution = GKShuffledDistribution(
            lowestValue: randomShuffledDistributionLowestValue,
            highestValue: randomShuffledDistributionHighestValue
        )
        
        // Set the Variance Random ranging -2 to +2 from Constant
        varianceDistribution = GKRandomDistribution(
            lowestValue: randomMinVariance,
            highestValue: randomMaxVariance
        )
        // Calculate thresholds dynamically based on the max deck size
        dynamicType1Threshold = Int(Double(randomShuffledDistributionHighestValue) * randomBlockType1Probability)  // Boundary line for Type 1: The bottom 60% of the deck.
        dynamicType2Threshold = Int(Double(randomShuffledDistributionHighestValue) * randomBlockType2Probability)  // Boundary line for Tier 2: The next 30% of the deck (Cumulative boundary = 90%).
    }
    
    // 4. The function to calculate HP based on your team's formula
    func generateFairHP(currentAmmo: Int) -> Int {
        // Draw a card from the deck (1 to the highest value)
        let roll = blockTypeDistribution.nextInt()
        
        // Get a variance (-2, -1, 0, 1, or 2)
        let variance = varianceDistribution.nextInt()
        let baseMultiplier: Double
        
        // 60% chance (Cards 1-6)
        if roll <= dynamicType1Threshold {
            baseMultiplier = randomBlockType1Multiplier
        }
        // 30% chance (Cards 7-9)
        else if roll <= dynamicType2Threshold {
            baseMultiplier = randomBlockType2Multiplier
        }
        // 10% chance (Card 10) - Guaranteed to only happen once every 10 blocks
        else {
            baseMultiplier = randomBlockType3Multiplier
        }
        
        let baseHP = Double(currentAmmo) * baseMultiplier
        // Apply variance and ensure HP is at least 1
        return max(1, Int(round(baseHP)) + variance)
    }
}

// TODO: Double check max catches negative HP calcu, so a block never spawns with 0 HP
