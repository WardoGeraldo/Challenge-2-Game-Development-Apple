import Foundation
import GameplayKit

class GameIdleState: GameState {
    // MARK: Properties

    // MARK: Initialization

    // MARK: GKState overrides
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // TODO: Do we need to do anything here?
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)

        // TODO: Do we need to do anything here?
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve and refilling states.
        return stateClass is GameAimState.Type
    }

    // MARK: Methods
}
