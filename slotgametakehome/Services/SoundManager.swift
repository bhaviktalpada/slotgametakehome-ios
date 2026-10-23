//
//  SoundManager.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.

import AVFoundation
import UIKit

/// Manages sound effects playback and haptic tactile feedback for the slot machine game.
/// Ensures single-shot audio playback (`numberOfLoops = 0`), handles audio session configuration,
/// and triggers mechanical impact and notification haptics.
final class SoundManager {

    // MARK: - Singleton Instance
    /// Shared singleton instance for application-wide audio management.
    static let shared = SoundManager()

    // MARK: - Audio Properties
    /// Primary audio player instance dedicated to reel spin sound effects.
    private var spinPlayer: AVAudioPlayer?

    // MARK: - Haptic Feedback Generators
    /// Medium impact generator for mechanical reel stop "clunk" sensations.
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    /// Light impact generator for spin button press tactile feedback.
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)

    /// Notification generator for win celebration vibration bursts.
    private let notificationFeedback = UINotificationFeedbackGenerator()

    // MARK: - Initialization

    /// Private initializer configuring audio sessions, preloading audio buffers, and warming haptic engines.
    private init() {
        setupAudioSession()
        prepareSpinAudio()
        impactFeedback.prepare()
        lightFeedback.prepare()
        notificationFeedback.prepare()
    }

    // MARK: - Audio Setup Process

    /// Configures the shared `AVAudioSession` with the `.ambient` category.
    /// This allows slot game sound effects to play without interrupting external background audio (e.g. music/podcasts).
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[SoundManager] Failed to configure AVAudioSession: \(error)")
        }
    }

    /// Loads and pre-buffers the spinning sound audio asset declared in `GameConfig.soundFileName`.
    /// Configures the player for single-shot execution (`numberOfLoops = 0`) to prevent unwanted looping.
    private func prepareSpinAudio() {
        let soundName = GameConfig.soundFileName
        let name: String
        let ext: String

        // Split sound file name and extension if present
        if let dotIndex = soundName.lastIndex(of: ".") {
            name = String(soundName[..<dotIndex])
            ext = String(soundName[soundName.index(after: dotIndex)...])
        } else {
            name = soundName
            ext = "wav"
        }

        // Locate sound file in application bundle
        guard let soundURL = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("[SoundManager] Warning: Sound file \(soundName) not found in bundle.")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.numberOfLoops = 0 // Play exactly one time per spin
            player.prepareToPlay()
            self.spinPlayer = player
        } catch {
            print("[SoundManager] Failed to initialize AVAudioPlayer: \(error)")
        }
    }

    // MARK: - Playback Control Process

    /// Plays the reel spinning sound once from the beginning.
    /// If the player is uninitialized, attempts to recreate and prepare the audio before playback.
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

    /// Immediately stops the spinning sound if playback is active.
    func stopSpinSound() {
        spinPlayer?.stop()
    }

    // MARK: - Haptic Feedback Process

    /// Triggers light tactile haptic feedback when the SPIN button is pressed.
    func playSpinStartFeedback() {
        lightFeedback.impactOccurred()
    }

    /// Triggers medium mechanical thud haptic feedback when an individual reel stops and spring settles.
    func playReelStopFeedback() {
        impactFeedback.impactOccurred()
    }

    /// Triggers a celebratory success haptic pattern when a spin produces a winning payline.
    func playWinFeedback() {
        notificationFeedback.notificationOccurred(.success)
    }
}
