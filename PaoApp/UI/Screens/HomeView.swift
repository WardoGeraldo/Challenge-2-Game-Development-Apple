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
    @State private var cachedScene: HomeScene?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(white: 0.67).ignoresSafeArea()
                SpriteView(scene: getScene(size: proxy.size))
                    .ignoresSafeArea()
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .ignoresSafeArea()
    }

    private func getScene(size: CGSize) -> HomeScene {
        if let s = cachedScene {
            s.onPlayTapped = onPlay
            return s
        }
        let s = HomeScene(fileNamed: "HomeScene") ?? HomeScene(size: size)
        s.scaleMode = .aspectFill
        s.onPlayTapped = onPlay
        cachedScene = s
        return s
    }
}

#Preview {
    HomeView(onPlay: {})
}
