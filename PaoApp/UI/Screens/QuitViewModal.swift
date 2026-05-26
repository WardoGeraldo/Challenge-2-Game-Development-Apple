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
    @State private var cachedScene: QuitConfirmationScene?

    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: getScene(size: proxy.size), options: [.allowsTransparency])
                .ignoresSafeArea()
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
    }

    private func getScene(size: CGSize) -> QuitConfirmationScene {
        if let s = cachedScene {
            s.onConfirm = onConfirm
            s.onCancel = onCancel
            return s
        }
        let s = QuitConfirmationScene(fileNamed: "QuitConfirmationScene") ?? QuitConfirmationScene(size: size)
        s.scaleMode = .aspectFill
        s.backgroundColor = .clear
        s.onConfirm = onConfirm
        s.onCancel = onCancel
        cachedScene = s
        return s
    }
}

#Preview {
    ZStack {
        QuitViewModal(onConfirm: {}, onCancel: {})
    }
}
