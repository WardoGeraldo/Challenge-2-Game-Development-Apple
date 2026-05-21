//
//  SoundManager.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import SpriteKit
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var bgmPlayer: AVAudioPlayer?
    private init() {}
    
    //list of background musics
    enum BGMTrack: String {
        case mainTheme = "backgroundMusic"
        case forestAmbience = "ambience"
    }
    //list of Sound Effects
    enum SFX: String {
        case hitBlock = "hitBlockSFX.wav"
        case shoot = "shootSFX.wav"
    }

    // MARK: Background Music
    //
    func playBGM(track: BGMTrack) {
        stopBGM()
        
        // Use track.rawValue to safely get the string (cth: "backgroundMusic")
        guard let url = Bundle.main.url(forResource: track.rawValue, withExtension: "mp3") else {
            print("Sound Error: Could not find \(track.rawValue).mp3")
            return
        }
        
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.numberOfLoops = -1
            bgmPlayer?.volume = 0.4
            bgmPlayer?.prepareToPlay()
            bgmPlayer?.play()
        } catch {
            print("Sound Error: \(error.localizedDescription)")
        }
    }
    
    func stopBGM() {
        bgmPlayer?.stop()
    }
    
    // ─────────────────────────────────────────
    // MARK: Sound Effects
    // ─────────────────────────────────────────
    // use SFX from list
    func playSFX(_ effect: SFX, on node: SKNode) {
        // Use effect.rawValue to get the exact file name safely
        let soundAction = SKAction.playSoundFileNamed(effect.rawValue, waitForCompletion: false)
        node.run(soundAction)
    }
    
}
// TODO: List all sounds

