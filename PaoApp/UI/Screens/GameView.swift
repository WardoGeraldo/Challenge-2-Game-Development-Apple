//
//  GameView.swift
//  PaoApp
//
//  Created by Saujana Shafi on 10/05/26.
//

import SpriteKit
import SwiftUI

// Presents GameScene using the full screen bounds (including safe area).
// GameScene internally reads safe area insets to position content correctly.
struct GameView: View {
    var onGameOver: () -> Void = { }
    var body: some View {
        GeometryReader { geo in
            SpriteView(scene: makeScene(size: geo.size))
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }

    private func makeScene(size: CGSize) -> GameScene {
        let scene = GameScene(size: size)
        // resizeFill keeps the scene exactly equal to the view — no letterboxing
        scene.scaleMode = .resizeFill
        scene.onGameOver = onGameOver
        return scene
    }
}

#Preview {
    GameView()
}
