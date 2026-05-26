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
    
    func generateBlockType() -> BlockType {
        // Draw a card from the deck (1 to the highest value)
        let roll = blockTypeDistribution.nextInt()

        switch roll {
        case 1...dynamicType1Threshold:
            return .low
        case (dynamicType1Threshold + 1)...dynamicType2Threshold:
            return .medium
        default:
            return .high
        }
    }
    
    // 4. The function to calculate HP based on your team's formula
    func generateFairHP(currentAmmo: Int, type: BlockType) -> Int {
        // Get a variance (-2, -1, 0, 1, or 2)
        let variance = varianceDistribution.nextInt()
        let baseMultiplier: Double
        
        switch type {
        case .low:
            baseMultiplier = randomBlockType1Multiplier
        case .medium:
            baseMultiplier = randomBlockType2Multiplier
        case .high:
            baseMultiplier = randomBlockType3Multiplier
        default:
            baseMultiplier = randomBlockType1Multiplier
        }
        
        let baseHP = Double(currentAmmo) * baseMultiplier
        // Apply variance and ensure HP is at least 1
        return max(1, Int(round(baseHP)) + variance)
    }
}

// TODO: Double check max catches negative HP calcu, so a block never spawns with 0 HP
