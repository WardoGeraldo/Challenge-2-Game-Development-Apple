//
//  PauseViewModal.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 20/05/26.
//

import SwiftUI
import SpriteKit

struct PauseViewModal: View {
    var onResume: () -> Void
    var onQuit: () -> Void
    var currentScore: Int
    var highScore: Int
    @State private var cachedScene: PauseSettingScene?

    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: getScene(size: proxy.size), options: [.allowsTransparency])
                .ignoresSafeArea()
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
    }

    private func getScene(size: CGSize) -> PauseSettingScene {
        if let s = cachedScene {
            s.onResume = onResume
            s.onQuit = onQuit
            s.currentScore = currentScore
            s.highScore = highScore
            return s
        }
        let s = PauseSettingScene(fileNamed: "PauseSettingScene") ?? PauseSettingScene(size: size)
        s.scaleMode = .aspectFill
        s.backgroundColor = .clear
        s.currentScore = currentScore
        s.highScore = highScore
        s.onResume = onResume
        s.onQuit = onQuit
        cachedScene = s
        return s
    }
}

#Preview {
    ZStack {
        PauseViewModal(onResume: {}, onQuit: {}, currentScore: 0, highScore: 0)
    }
}
