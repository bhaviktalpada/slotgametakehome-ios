//
//  GameEngine.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.
//

import Foundation

struct SpinResult {
    let symbols: [SlotSymbol]
    let isWin: Bool
    let payout: Int
    let winAmount: Int

    var winningSymbol: SlotSymbol? {
        isWin ? symbols.first : nil
    }
}

struct GameState {
    var credits: Int = GameConfig.initialCredits
    var currentBet: Int = GameConfig.defaultBet
    var totalSpins: Int = 0
    var biggestWin: Int = 0
    var totalWinnings: Int = 0

    mutating func reset() {
        credits = GameConfig.initialCredits
        currentBet = GameConfig.defaultBet
        totalSpins = 0
        biggestWin = 0
        totalWinnings = 0
    }
}

final class GameEngine {

    private var state: GameState
    private let preferences: StorePreference

    init(preferences: StorePreference = .shared) {
        self.preferences = preferences
        self.state = preferences.loadGameState()
    }

    var currentState: GameState {
        state
    }

    // Check if coint available greater than current bet count
    func canSpin() -> Bool {
        state.credits >= state.currentBet
    }

    func setBet(_ bet: Int) { // Update latest bet count in preferences
        guard GameConfig.betOptions.contains(bet) else { return }
        state.currentBet = bet
        preferences.saveGameState(state)
    }

    // Core spin logic: deducts bet, determines outcome, calculates payout, and persists state
    func spin(forcedSymbols: [SlotSymbol]? = nil) -> SpinResult {
        guard canSpin() else {
            return SpinResult(symbols: [], isWin: false, payout: 0, winAmount: 0)
        }

        // Deduct bet and bump spin count
        state.credits -= state.currentBet
        state.totalSpins += 1

        // Use test outcome if provided, otherwise roll random weighted symbols
        let resultSymbols: [SlotSymbol]
        if let forced = forcedSymbols, forced.count == 3 {
            resultSymbols = forced
        } else {
            resultSymbols = (0..<3).map { _ in SlotSymbol.randomWeighted() }
        }

        // Check if all 3 match on the payline
        let (isWin, payout) = evaluateWin(resultSymbols)
        let winAmount = isWin ? state.currentBet * payout : 0

        if isWin {
            state.credits += winAmount
            state.totalWinnings += winAmount
            if winAmount > state.biggestWin {
                state.biggestWin = winAmount
            }
        }

        preferences.saveGameState(state)

        return SpinResult(
            symbols: resultSymbols,
            isWin: isWin,
            payout: payout,
            winAmount: winAmount
        )
    }

    /// check result of the win if match all match in 3 column return result
    private func evaluateWin(_ symbols: [SlotSymbol]) -> (Bool, Int) {
        guard symbols.count == 3 else { return (false, 0) }

        if symbols[0] == symbols[1] && symbols[1] == symbols[2] {
            return (true, symbols[0].payout)
        }
        return (false, 0)
    }

    func resetGame() {
        state.reset()
        preferences.reset()
    }
}
