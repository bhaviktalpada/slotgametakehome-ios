//
//  StorePreference.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.

import Foundation

/// Manages persistent storage of player scores, credits balance, last bet, and game statistics using `UserDefaults`.
/// Guarantees that player progress, high scores, and session history survive app restarts and launches.
final class StorePreference {

    // MARK: - Singleton Instance
    /// Shared singleton instance for convenient application-wide access.
    static let shared = StorePreference()

    // MARK: - Dependencies
    /// The underlying `UserDefaults` backing store.
    private let userDefaults: UserDefaults

    // MARK: - Storage Keys
    /// Dedicated key constants organized in a private namespace to prevent key collisions.
    private enum Keys {
        static let credits = "slot_game_credits"
        static let biggestWin = "slot_game_biggest_win"
        static let totalSpins = "slot_game_total_spins"
        static let totalWinnings = "slot_game_total_winnings"
        static let lastBet = "slot_game_last_bet"
        static let hasSavedData = "slot_game_has_saved_data"
    }

    // MARK: - Initialization

    /// Initializes the persistence manager with a specified `UserDefaults` suite (defaults to `.standard`).
    /// - Parameter userDefaults: Target UserDefaults instance (injected for unit testing).
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Saved State Indicator

    /// Returns true if valid game data has previously been saved to storage.
    var hasSavedData: Bool {
        return userDefaults.bool(forKey: Keys.hasSavedData)
    }

    // MARK: - Score & Balance Properties

    /// Persisted player credit balance. Returns `GameConfig.initialCredits` if no save exists yet.
    var credits: Int {
        get {
            if hasSavedData {
                return userDefaults.integer(forKey: Keys.credits)
            }
            return GameConfig.initialCredits
        }
        set {
            userDefaults.set(newValue, forKey: Keys.credits)
            userDefaults.set(true, forKey: Keys.hasSavedData)
        }
    }

    /// Highest single win payout achieved across all spins.
    var biggestWin: Int {
        get { return userDefaults.integer(forKey: Keys.biggestWin) }
        set {
            userDefaults.set(newValue, forKey: Keys.biggestWin)
            userDefaults.set(true, forKey: Keys.hasSavedData)
        }
    }

    /// Total count of completed spins in this installation.
    var totalSpins: Int {
        get { return userDefaults.integer(forKey: Keys.totalSpins) }
        set {
            userDefaults.set(newValue, forKey: Keys.totalSpins)
            userDefaults.set(true, forKey: Keys.hasSavedData)
        }
    }

    /// Cumulative total credits won across all winning spins.
    var totalWinnings: Int {
        get { return userDefaults.integer(forKey: Keys.totalWinnings) }
        set {
            userDefaults.set(newValue, forKey: Keys.totalWinnings)
            userDefaults.set(true, forKey: Keys.hasSavedData)
        }
    }

    /// Last selected bet denomination (defaults to `GameConfig.defaultBet` if unset).
    var lastBet: Int {
        get {
            let saved = userDefaults.integer(forKey: Keys.lastBet)
            return saved > 0 ? saved : GameConfig.defaultBet
        }
        set {
            userDefaults.set(newValue, forKey: Keys.lastBet)
            userDefaults.set(true, forKey: Keys.hasSavedData)
        }
    }

    // MARK: - GameState Operations Process

    /// Saves the complete game state (credits, last bet, statistics) to `UserDefaults`.
    /// - Parameter state: The active `GameState` struct to persist.
    func saveGameState(_ state: GameState) {
        credits = state.credits
        biggestWin = state.biggestWin
        totalSpins = state.totalSpins
        totalWinnings = state.totalWinnings
        lastBet = state.currentBet
        userDefaults.set(true, forKey: Keys.hasSavedData)
    }

    /// Loads the stored game state from `UserDefaults`.
    /// If no previous save exists, returns an initialized `GameState` with defaults from `GameConfig`.
    /// - Returns: Restored or initial `GameState`.
    func loadGameState() -> GameState {
        guard hasSavedData else {
            return GameState(
                credits: GameConfig.initialCredits,
                currentBet: GameConfig.defaultBet,
                totalSpins: 0,
                biggestWin: 0,
                totalWinnings: 0
            )
        }

        return GameState(
            credits: credits,
            currentBet: lastBet,
            totalSpins: totalSpins,
            biggestWin: biggestWin,
            totalWinnings: totalWinnings
        )
    }

    /// Clears all stored keys and removes saved data, resetting storage back to fresh installation state.
    func reset() {
        userDefaults.removeObject(forKey: Keys.credits)
        userDefaults.removeObject(forKey: Keys.biggestWin)
        userDefaults.removeObject(forKey: Keys.totalSpins)
        userDefaults.removeObject(forKey: Keys.totalWinnings)
        userDefaults.removeObject(forKey: Keys.lastBet)
        userDefaults.removeObject(forKey: Keys.hasSavedData)
    }
}
