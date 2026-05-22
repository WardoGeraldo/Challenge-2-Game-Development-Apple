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
    
    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: makeScene(size: proxy.size), options: [.allowsTransparency])
                .ignoresSafeArea()
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
    }
    
    private func makeScene(size: CGSize) -> PauseSettingScene {
        // Loads the .sks file 
        let scene = PauseSettingScene(fileNamed: "PauseSettingScene") ?? PauseSettingScene(size: size)
        
        scene.scaleMode = .aspectFill
        scene.currentScore = currentScore
        scene.highScore = highScore
        scene.onResume = onResume
        scene.onQuit = onQuit
        
        // .clear background
        scene.backgroundColor = .clear
        
        return scene
    }
}

#Preview {
    ZStack {
//        Color.blue  //Placeholder game background
        PauseViewModal(onResume: {}, onQuit: {},currentScore: 0, highScore:0)
    }
}
