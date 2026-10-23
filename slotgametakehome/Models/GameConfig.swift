//
//  GameConfig.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.
//

import Foundation

enum AppEnvironment: String, CaseIterable {
    case development = "Development"
    case production = "Production"
}

// Predefined outcomes for QA / testing in development mode
enum PredefinedSpinOption: String, CaseIterable {
    case random = "🎲 Random"
    case cherry = "🍒 Cherry (2x)"
    case lemon = "🍋 Lemon (3x)"
    case seven = "7️⃣ Seven (5x)"
    case bell = "🔔 Bell (10x)"
    case star = "⭐ Star (15x)"
    case diamond = "💎 Diamond (25x)"
    case loss = "❌ No Win"

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

// Global game settings, timings, and economy values
enum GameConfig {
    // Current environment - dev shows QA HUD, prod hides it
    static var environment: AppEnvironment = .development
    static var selectedTestOption: PredefinedSpinOption = .random

    // Sound file name in bundle
    static let soundFileName = "spinning-sound.wav"

    // Reel spin timings
    static var baseSpinDuration: TimeInterval = 3.0
    static let reelStaggerDelay: TimeInterval = 0.35 // delay between reel stops
    static let spinStepInterval: TimeInterval = 0.04  // frame rate of spinning symbols
    static let winAnimationDuration: TimeInterval = 0.7
    static let resultAnimationDuration: TimeInterval = 0.35

    // Economy
    static let initialCredits: Int = 100
    static let betOptions: [Int] = [1, 5, 10]
    static let defaultBet: Int = 1
}
