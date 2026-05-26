//
//  ContentView.swift
//  PaoApp
//
//  Created by Saujana Shafi on 01/05/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isPlaying = false

    var body: some View {
        ZStack {
            HomeView(onPlay: { isPlaying = true })
            if isPlaying {
                GameView(onGameOver: { isPlaying = false })
            }
        }
    }
}

#Preview {
    ContentView()
}
