//
//  ControlComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

class ControlComponent: GKComponent {
    var pointTo: CGPoint

    var nextRoundPosition: CGPoint?

    var constraint: SKConstraint {
        return SKConstraint.orient(
            to: self.pointTo,
            offset: SKRange(constantValue: -CGFloat.pi / 2),
        )
    }

    func orient(to position: CGPoint) {
        self.pointTo = position
    }

    init(pointTo: CGPoint) {
        self.pointTo = pointTo

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
