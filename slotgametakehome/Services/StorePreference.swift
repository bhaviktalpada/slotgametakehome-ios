//
//  StorePreference.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.
//

import Foundation

// Handles persisting player credits and session stats to UserDefaults
final class StorePreference {

    static let shared = StorePreference()

    private let userDefaults: UserDefaults

    private enum Keys {
        static let credits = "slot_game_credits"
        static let biggestWin = "slot_game_biggest_win"
        static let totalSpins = "slot_game_total_spins"
        static let totalWinnings = "slot_game_total_winnings"
        static let lastBet = "slot_game_last_bet"
        static let hasSavedData = "slot_game_has_saved_data"
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasSavedData: Bool {
        userDefaults.bool(forKey: Keys.hasSavedData)
    }

    var credits: Int {
        get {
            hasSavedData ? userDefaults.integer(forKey: Keys.credits) : GameConfig.initialCredits
        }
        set {
            userDefaults.set(newValue, forKey: Keys.credits)
            userDefaults.set(true, forKey: Keys.hasSavedData)
        }
    }

    var biggestWin: Int {
        get { userDefaults.integer(forKey: Keys.biggestWin) }
        set {
            userDefaults.set(newValue, forKey: Keys.biggestWin)
            userDefaults.set(true, forKey: Keys.hasSavedData)
        }
    }

    var totalSpins: Int {
        get { userDefaults.integer(forKey: Keys.totalSpins) }
        set {
            userDefaults.set(newValue, forKey: Keys.totalSpins)
            userDefaults.set(true, forKey: Keys.hasSavedData)
        }
    }

    var totalWinnings: Int {
        get { userDefaults.integer(forKey: Keys.totalWinnings) }
        set {
            userDefaults.set(newValue, forKey: Keys.totalWinnings)
            userDefaults.set(true, forKey: Keys.hasSavedData)
        }
    }

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

    func saveGameState(_ state: GameState) {
        credits = state.credits
        biggestWin = state.biggestWin
        totalSpins = state.totalSpins
        totalWinnings = state.totalWinnings
        lastBet = state.currentBet
        userDefaults.set(true, forKey: Keys.hasSavedData)
    }

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

    func reset() {
        [Keys.credits, Keys.biggestWin, Keys.totalSpins, Keys.totalWinnings, Keys.lastBet, Keys.hasSavedData].forEach {
            userDefaults.removeObject(forKey: $0)
        }
    }
}
