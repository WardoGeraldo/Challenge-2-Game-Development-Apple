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
        if isPlaying {
            GameView(onGameOver: {
                isPlaying = false })
        } else {
            HomeView(onPlay: { isPlaying = true })
        }
    }
}

#Preview {
    ContentView()
}
