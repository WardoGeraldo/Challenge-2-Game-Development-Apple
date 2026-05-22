//
//  GridComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 15/05/26.
//

import Foundation
import GameplayKit

class GridComponent: GKComponent {
    private var _row: Int
    private var _col: Int

    var row: Int {
        get { _row }
        set {
            _row = newValue
            // Update the transform component's y based on row
            if let transform = entity?.component(
                ofType: TransformComponent.self
            ) {
                transform.position.y = CGFloat(newValue) * kCell + kCell / 2
            }
        }
    }
    var col: Int {
        get { _col }
        set {
            _col = newValue
            // Update the transform component's x based on col
            if let transform = entity?.component(
                ofType: TransformComponent.self
            ) {
                transform.position.x = CGFloat(newValue) * kCell + kCell / 2
            }
        }
    }

    // Accessing the parent's position (read-only convenience)
    var position: CGPoint? {
        return entity?.component(ofType: TransformComponent.self)?.position
    }

    init(row: Int, col: Int) {
        self._row = row
        self._col = col

        super.init()

        // Use setters so transform (when available later) will be updated accordingly
        self.row = row
        self.col = col
    }

    override func didAddToEntity() {
        super.didAddToEntity()
        // Now 'entity' is not nil; position the transform based on current row/col
        if let transformComponent = entity?.component(
            ofType: TransformComponent.self
        ) {
            transformComponent.position.x = CGFloat(col) * kCell + (kCell / 2)
            transformComponent.position.y = CGFloat(row) * kCell + (kCell / 2)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
