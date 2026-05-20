//
//  QuitViewModal.swift
//  PaoApp
//
//  Created by Axel Valent Prayogo on 20/05/26.
//

import SwiftUI
import SpriteKit

struct QuitViewModal: View {
    var onConfirm: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: makeScene(size: proxy.size), options: [.allowsTransparency])
                .ignoresSafeArea()
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
    }
    
    private func makeScene(size: CGSize) -> QuitConfirmationScene {
        // Ensure "QuitConfirmationScene" matches your exact .sks filename
        let scene = QuitConfirmationScene(fileNamed: "QuitConfirmationScene") ?? QuitConfirmationScene(size: size)
        
        scene.scaleMode = .aspectFill
        scene.onConfirm = onConfirm
        scene.onCancel = onCancel
        scene.backgroundColor = .clear // Transparent background
        
        return scene
    }
}
#Preview {
    ZStack {
        QuitViewModal(onConfirm: {}, onCancel: {})
    }
}
