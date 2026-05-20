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
    @State private var isPaused: Bool = false
    @State private var showQuitConfirm: Bool = false
//    @State private var settings = SettingsManager()
    
    var body: some View {
        // 2. The ZStack creates the layers
        ZStack {
            
            // --- LAYER 1: THE GAME ---
            GeometryReader { geo in
                SpriteView(scene: makeScene(size: geo.size))
                    .ignoresSafeArea()
            }
            .ignoresSafeArea()
            
            // --- LAYER 2: THE PAUSE BUTTON ---
            if !isPaused && !showQuitConfirm {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isPaused = true
                        }) {
                            // Temporary placeholder button
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
            
            // --- LAYER 3: THE PAUSE MENU ---
            if isPaused && !showQuitConfirm {
                Color.black.opacity(0.5).ignoresSafeArea() // Dim background
                
                PauseViewModal(
//                    settings: settings,
                    onResume: { isPaused = false },
                    onQuit: { showQuitConfirm = true }
                )
            }
            
            // --- LAYER 4: THE QUIT CONFIRMATION ---
            if showQuitConfirm {
                Color.black.opacity(0.7).ignoresSafeArea()
                
                QuitViewModal(
                    onConfirm: { onGameOver() },
                    onCancel: { showQuitConfirm = false }
                )
            }
        }
    }
    
    private func makeScene(size: CGSize) -> GameScene {
        let scene = GameScene(size: size)
        // resizeFill keeps the scene exactly equal to the view — no letterboxing
        scene.scaleMode = .resizeFill
        scene.onGameOver = onGameOver
        
        //By adding scene.isPaused = isPaused inside  makeScene function, you just created a two-way street. When the player taps the SwiftUI Pause button, the @State changes to true. SwiftUI instantly re-renders the view, shows the PauseView, and simultaneously tells your underlying Apple GameScene to freeze all physics and movement.
        scene.isPaused = isPaused
        return scene
    }
}

#Preview {
    GameView()
}
