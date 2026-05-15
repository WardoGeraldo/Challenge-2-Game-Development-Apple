//
//  HomeView.swift
//  PaoApp
//
//  Created by Saujana Shafi on 10/05/26.
//

import SpriteKit
import SwiftUI

struct HomeView: View {
    var onPlay: () -> Void

    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: makeScene(size: proxy.size))
                .ignoresSafeArea()
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
    }

    private func makeScene(size: CGSize) -> HomeScene {
        let scene = HomeScene(fileNamed: "HomeScene") ?? HomeScene(size: size)
        scene.scaleMode = .aspectFill
        scene.onPlayTapped = onPlay
        return scene
    }
}

#Preview {
    HomeView(onPlay: {})
}
