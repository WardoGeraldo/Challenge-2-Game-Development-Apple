//
//  ArenaComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 18/05/26.
//

import Foundation
import GameplayKit

class ArenaComponent: GKComponent {
    var col: Int
    var row: Int

    init(
        col: Int,
        row: Int,
    ) {
        self.col = col
        self.row = row

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
