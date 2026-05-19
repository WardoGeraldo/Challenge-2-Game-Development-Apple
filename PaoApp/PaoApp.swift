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
    init() {
        if let url = Bundle.main.url(forResource: "MelonPop", withExtension: "otf") {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
