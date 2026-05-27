//
//  GameView.swift
//  PaoApp
//
//  Created by Saujana Shafi on 10/05/26.
//

import SpriteKit
import SwiftUI

struct GameView: View {
    var onGameOver: () -> Void = { }
    @State private var isPaused = false
    @State private var showQuitConfirm = false
    @State private var showGameOverModal = false
    @State private var isNewHighScore = false
    @State private var displayScore = 0
    @State private var displayHighScore = 0
    @State private var sceneSize: CGSize = .zero
    @State private var gameScene: GameScene?
    @State private var sessionID = 0
    @State private var sessionHighScore = 0

    var body: some View {
        ZStack {
            // LAYER 1: THE GAME
            GeometryReader { geo in
                ZStack {
                    Color.black.ignoresSafeArea()
                    Color.clear
                        .onAppear {
                            guard gameScene == nil else { return }
                            startNewGame(size: geo.size)
                        }
                    if let scene = gameScene {
                        SpriteView(scene: scene)
                            .ignoresSafeArea()
                            .id(sessionID)
                    }
                }
            }
            .ignoresSafeArea()

            // LAYER 2: PAUSE MENU
            let showPause = isPaused && !showQuitConfirm
            Color.black.opacity(showPause ? 0.5 : 0).ignoresSafeArea()
                .allowsHitTesting(false)
            PauseViewModal(
                onResume: {
                    gameScene?.isPaused = false
                    isPaused = false
                },
                onQuit: { showQuitConfirm = true },
                currentScore: ScoreManager.shared.currentScore,
                highScore: sessionHighScore
            )
            .opacity(showPause ? 1 : 0)
            .allowsHitTesting(showPause)

            // LAYER 3: QUIT CONFIRMATION
            Color.black.opacity(showQuitConfirm ? 0.7 : 0).ignoresSafeArea()
                .allowsHitTesting(false)
            QuitViewModal(
                onConfirm: {
                    ScoreManager.shared.submit()
                    gameScene = nil
                    onGameOver()
                },
                onCancel: {
                    showQuitConfirm = false
                    isPaused = false
                    gameScene?.isPaused = false
                }
            )
            .opacity(showQuitConfirm ? 1 : 0)
            .allowsHitTesting(showQuitConfirm)

            // LAYER 4: GAME OVER MODAL
            if showGameOverModal {
                Color.black.opacity(0.5).ignoresSafeArea()
                if isNewHighScore {
                    NewHighScoreViewModal(
                        score: displayScore,
                        highscore: displayHighScore,
                        onClose: {
                            showGameOverModal = false
                            onGameOver()
                        },
                        onPlayAgain: {
                            showGameOverModal = false
                            startNewGame(size: sceneSize)
                        }
                    )
                } else {
                    GameOverViewModal(
                        score: displayScore,
                        highscore: displayHighScore,
                        onClose: {
                            showGameOverModal = false
                            onGameOver()
                        },
                        onPlayAgain: {
                            showGameOverModal = false
                            startNewGame(size: sceneSize)
                        }
                    )
                }
            }
        }
    }

    private func startNewGame(size: CGSize) {
        ScoreManager.shared.reset()
        sessionHighScore = ScoreManager.shared.highScore
        sceneSize = size
        sessionID += 1
        let scene = GameScene(size: size)
        scene.backgroundColor = .black 
        scene.scaleMode = .resizeFill
        scene.onPause = { isPaused = true }
        scene.onGameOver = {
            displayScore = ScoreManager.shared.currentScore
            let newRecord = ScoreManager.shared.submit()
            displayHighScore = ScoreManager.shared.highScore
            isNewHighScore = newRecord
            showGameOverModal = true
        }
        gameScene = scene
    }
}

#Preview {
    GameView()
}
