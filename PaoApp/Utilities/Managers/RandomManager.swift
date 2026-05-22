//
//  RandomManager.swift
//  PaoApp
//
//  Created by Saujana Shafi on 20/05/26.
//

import Foundation
import GameplayKit

class RandomManager {
    static let shared = RandomManager()

    private let totalWeight: Int
    private var randomEntity: GKShuffledDistribution
    private var randomColumn: GKShuffledDistribution
    private let randomVariance: GKRandomDistribution
    private let randomQuantity: GKRandomDistribution

    private init() {
        totalWeight = kRandom.allCases.reduce(0) { $0 + $1.weight }
        randomEntity = RandomManager.makeEntityDistribution(
            totalWeight: totalWeight
        )
        randomColumn = RandomManager.makeColumnDistribution()
        randomVariance = RandomManager.makeVarianceDistribution()
        randomQuantity = RandomManager.makeQuantityDistribution()
    }

    // MARK: Methods

    func getRandomEntity() -> kRandom {
        let roll = randomEntity.nextInt()
        var current = 0

        for kind in kRandom.allCases {
            current += kind.weight
            if roll < current {
                return kind
            }
        }

        return .lowBlock
    }

    func getRandomColumn() -> Int {
        return randomColumn.nextInt()
    }

    func getRandomVariance() -> Int {
        return randomVariance.nextInt()
    }

    func getRandomQuantity() -> Int {
        return randomQuantity.nextInt()
    }

    func resetRandomColumn() {
        randomColumn = RandomManager.makeColumnDistribution()
    }

    private static func makeEntityDistribution(
        totalWeight: Int
    ) -> GKShuffledDistribution {
        GKShuffledDistribution(
            randomSource: GKARC4RandomSource(),
            lowestValue: 0,
            highestValue: totalWeight - 1,
        )
    }

    private static func makeColumnDistribution() -> GKShuffledDistribution {
        GKShuffledDistribution(
            randomSource: GKARC4RandomSource(),
            lowestValue: 0,
            highestValue: kColumns - 1,
        )
    }

    private static func makeVarianceDistribution() -> GKRandomDistribution {
        GKRandomDistribution(
            lowestValue: randomMinVariance,
            highestValue: randomMaxVariance,
        )
    }

    private static func makeQuantityDistribution() -> GKRandomDistribution {
        GKRandomDistribution(
            lowestValue: kRandomGenerationsPerRowMin,
            highestValue: kRandomGenerationsPerRowMax,
        )
    }
}
