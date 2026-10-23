//
//  GameConfig.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.

import Foundation

/// Defines the execution mode of the application.
/// - In `.development`: Developer HUD controls are visible, allowing testers to select predefined spin outcomes.
/// - In `.production`: Developer HUD controls are completely hidden for a clean production user experience.
enum AppEnvironment: String, CaseIterable {
    case development = "Development"
    case production = "Production"
}

/// Predefined outcome options available in Development mode for rapid QA testing of game logic and payout multipliers.
enum PredefinedSpinOption: String, CaseIterable {
    case random = "🎲 Random"
    case cherry = "🍒 Cherry (2x)"
    case lemon = "🍋 Lemon (3x)"
    case seven = "7️⃣ Seven (5x)"
    case bell = "🔔 Bell (10x)"
    case star = "⭐ Star (15x)"
    case diamond = "💎 Diamond (25x)"
    case loss = "❌ No Win"

    /// The exact 3 symbols to force onto the center payline for this option.
    /// Returns `nil` when `.random` is selected so standard weighted RNG is applied.
    var forcedSymbols: [SlotSymbol]? {
        switch self {
        case .random:
            return nil
        case .cherry:
            return [.cherry, .cherry, .cherry]
        case .lemon:
            return [.lemon, .lemon, .lemon]
        case .seven:
            return [.seven, .seven, .seven]
        case .bell:
            return [.bell, .bell, .bell]
        case .star:
            return [.star, .star, .star]
        case .diamond:
            return [.diamond, .diamond, .diamond]
        case .loss:
            return [.cherry, .lemon, .seven]
        }
    }
}

/// Central configuration store for constants, animation physics, audio filenames,
/// QA environment settings, and game economy values.
enum GameConfig {

    // MARK: - Environment Configuration
    /// Current app execution environment. Controls visibility of the Developer HUD.
    static var environment: AppEnvironment = .development

    /// Currently selected predefined spin result option (active only in `.development` mode).
    static var selectedTestOption: PredefinedSpinOption = .random

    // MARK: - Audio Configuration
    /// The filename of the reel spinning audio asset in the app bundle.
    static let soundFileName: String = "spinning-sound.wav"

    // MARK: - Animation Timings (in seconds)
    /// Base duration for the first reel column (Reel 0) to spin before settling.
    static var baseSpinDuration: TimeInterval = 2.8

    /// Sequential delay added to each subsequent reel stop to produce realistic staggered mechanical stops:
    /// - Reel 0 stops at: `baseSpinDuration`
    /// - Reel 1 stops at: `baseSpinDuration + reelStaggerDelay`
    /// - Reel 2 stops at: `baseSpinDuration + (2 * reelStaggerDelay)`
    static let reelStaggerDelay: TimeInterval = 0.35

    /// Base interval between symbol frame shifts during high-speed spinning.
    static let spinStepInterval: TimeInterval = 0.04

    /// Duration of the winning symbol pulsing bounce celebration animation.
    static let winAnimationDuration: TimeInterval = 0.7

    /// Duration for result and status label spring pop-in transitions.
    static let resultAnimationDuration: TimeInterval = 0.35

    // MARK: - Game Economy Configuration
    /// Starting credit balance allocated to the player upon initial launch or reset.
    static let initialCredits: Int = 100

    /// Available bet denomination choices presented in the segmented control.
    static let betOptions: [Int] = [1, 5, 10]

    /// Default bet denomination selected when the game is first launched.
    static let defaultBet: Int = 1
}
