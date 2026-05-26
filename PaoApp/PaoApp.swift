//
//  PaoApp.swift
//  PaoApp
//
//  Created by Saujana Shafi on 01/05/26.
//

import SwiftUI
import CoreText

@main
struct PaoApp: App {
    @Environment(\.scenePhase) private var scenePhase
    init() {
        if let url = Bundle.main.url(forResource: "MelonPop", withExtension: "otf") {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, phase in
                      if phase == .background {
                          ScoreManager.shared.submit()
                      }
                  }  
    }
}
