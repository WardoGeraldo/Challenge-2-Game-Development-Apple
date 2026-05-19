//
//  ConsumableComponent.swift
//  PaoApp
//
//  Created by Saujana Shafi on 07/05/26.
//

import Foundation
import GameplayKit

class ConsumableComponent: GKComponent {
    let onConsumed: () -> Void

    init(onConsumed: @escaping () -> Void) {
        self.onConsumed = onConsumed

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
