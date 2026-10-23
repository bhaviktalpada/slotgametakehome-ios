//
//  SoundManager.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.
//

import AVFoundation
import UIKit

final class SoundManager {

    static let shared = SoundManager()

    private var spinPlayer: AVAudioPlayer?
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private init() {
        setupAudioSession()
        prepareSpinAudio()
        impactFeedback.prepare()
        lightFeedback.prepare()
        notificationFeedback.prepare()
    }

    private func setupAudioSession() {
        do {
            // Ambient allows sound effects without cutting off Spotify/Apple Music
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("SoundManager: Audio session error: \(error)")
        }
    }

    // Prepare spin audio function
    private func prepareSpinAudio() {
        guard let url = Bundle.main.url(forResource: "spinning-sound", withExtension: "wav") else {
            print("SoundManager: spinning-sound.wav not found in bundle")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = 0 // play once per spin
            player.prepareToPlay()
            self.spinPlayer = player
        } catch {
            print("SoundManager: Failed to init audio player: \(error)")
        }
    }

    // Play spinning audo 
    func playSpinSound() {
        guard let player = spinPlayer else {
            prepareSpinAudio()
            spinPlayer?.currentTime = 0
            spinPlayer?.play()
            return
        }
        player.currentTime = 0
        player.play()
    }

    func stopSpinSound() {
        spinPlayer?.stop()
    }

    // Haptics
    func playSpinStartFeedback() {
        lightFeedback.impactOccurred()
    }

    func playReelStopFeedback() {
        impactFeedback.impactOccurred()
    }

    func playWinFeedback() {
        notificationFeedback.notificationOccurred(.success)
    }
}
