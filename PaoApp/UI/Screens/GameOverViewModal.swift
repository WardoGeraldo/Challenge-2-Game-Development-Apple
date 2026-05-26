import Foundation
import SwiftUI
import SpriteKit

struct GameOverViewModal: View {

    var score: Int
    var highscore: Int

    var onClose: () -> Void
    var onPlayAgain: () -> Void

    var body: some View {

        GeometryReader { proxy in

            SpriteView(
                scene: makeScene(size: proxy.size),
                options: [.allowsTransparency]
            )
            .ignoresSafeArea()
            .frame(
                width: proxy.size.width,
                height: proxy.size.height
            )
        }
        .ignoresSafeArea()
    }

    private func makeScene(
        size: CGSize
    ) -> GameOverModalScene {

        let scene =
        GameOverModalScene(
            fileNamed: "GameOverModalScene"
        )
        ?? GameOverModalScene(size: size)

        scene.size = size
        scene.score = score
        scene.highscore = highscore
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear

        scene.onClose = {
            onClose()
        }

        scene.onPlayAgain = {
            onPlayAgain()
        }
        return scene
    }
}

#Preview {

    GameOverViewModal(
        score: 258,
        highscore: 9999999,
        onClose: {},
        onPlayAgain: {}
    )
}
