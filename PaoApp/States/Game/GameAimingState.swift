//
//  GameAimingState.swift
//  PaoApp
//
//  Created by Axel on 13/05/26.
//

import GameplayKit

// Active while the player drags to aim. Tracks the pan angle and updates the
// guiding arrow. Commits the shot when the drag ends.
class GameAimingState: GKState {

    weak var context: GameStateContext?

    init(context: GameStateContext) {
        self.context = context
        super.init()
    }

    // MARK: - Called by GameScene's pan gesture handler

    /// Updates the guiding arrow as the player drags.
    func updateAim(angle: CGFloat) {
        guard let origin = context?.shooterPosition else { return }
        context?.showAimLine(from: origin, angle: angle)
    }

    /// Locks in the shot angle and transitions to the flying state.
    func commitShot(angle: CGFloat) {
        context?.pendingShotAngle = angle
        stateMachine?.enter(GameFlyingState.self)
    }

    // MARK: - GKState

    override func willExit(to nextState: GKState) {
        context?.hideAimLine()
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        stateClass == GameFlyingState.self
    }
}
