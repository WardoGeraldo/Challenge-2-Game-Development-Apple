//
//  GameView.swift
//  PaoApp
//
//  Created by Saujana Shafi on 10/05/26.
//

import SpriteKit
import SwiftUI

struct GameView: View {
    var body: some View {
        GeometryReader { proxy in
            SpriteView(
                scene: GameScene(
                    size: proxy.size
                )
            )
            .ignoresSafeArea()
            .frame(
                width: proxy.size.width,
                height: proxy.size.height,
                alignment: .center,
            )
        }
    }
}

#Preview {
    GameView()
}
