//
//  GameEngine.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.

import Foundation

/// Represents the evaluated outcome of an individual slot machine spin.
struct SpinResult {
    /// The symbols settled across the center payline for reels 0, 1, and 2.
    let symbols: [SlotSymbol]

    /// True if all three symbols on the center payline match.
    let isWin: Bool

    /// Payout multiplier associated with the winning symbol (0 for losses).
    let payout: Int

    /// Total credit amount won on this spin (bet * payout).
    let winAmount: Int

    /// The winning symbol if the spin was successful; otherwise nil.
    var winningSymbol: SlotSymbol? {
        guard isWin else { return nil }
        return symbols.first
    }
}

/// Represents the player's lifetime game session state and statistics.
struct GameState {
    /// Available credit balance for placing bets.
    var credits: Int = GameConfig.initialCredits

    /// Currently selected bet denomination per spin.
    var currentBet: Int = GameConfig.defaultBet

    /// Total number of spins completed in the lifetime of this installation.
    var totalSpins: Int = 0

    /// Largest single payout achieved in any individual spin.
    var biggestWin: Int = 0

    /// Cumulative total of all winnings credited to the player across all spins.
    var totalWinnings: Int = 0

    /// Restores the game state back to default initial values.
    mutating func reset() {
        credits = GameConfig.initialCredits
        currentBet = GameConfig.defaultBet
        totalSpins = 0
        biggestWin = 0
        totalWinnings = 0
    }
}

/// Core game engine responsible for state transitions, bet validation,
/// weighted random outcome generation, payline evaluation, and persistence coordination.
final class GameEngine {

    // MARK: - Properties
    /// Active game state tracking balance and session statistics.
    private var state: GameState

    /// Persistence store interface for UserDefaults synchronization.
    private let preferences: StorePreference

    // MARK: - Initialization

    /// Initializes the game engine and loads persisted state from storage.
    /// - Parameter preferences: Storage preference service (defaults to `.shared`).
    init(preferences: StorePreference = .shared) {
        self.preferences = preferences
        self.state = preferences.loadGameState()
    }

    // MARK: - Public State Accessors

    /// Read-only snapshot of the current game state.
    var currentState: GameState {
        return state
    }

    // MARK: - Bet Validation & Mutation Process

    /// Validates whether the player has sufficient credits to execute a spin.
    /// - Returns: True if current credits balance is greater than or equal to current bet.
    func canSpin() -> Bool {
        return state.credits >= state.currentBet
    }

    /// Updates the active bet denomination and persists the choice to storage.
    /// - Parameter bet: The bet amount selected by the player.
    func setBet(_ bet: Int) {
        state.currentBet = bet
        preferences.saveGameState(state)
    }

    // MARK: - Spin Execution & Outcome Evaluation Process

    /// Executes a slot machine spin through the following deterministic sequence:
    /// 1. Balance Validation: Verifies `credits >= currentBet`. If insufficient, returns a zeroed non-win result.
    /// 2. Deduction & Tracking: Deducts `currentBet` immediately from balance and increments `totalSpins`.
    /// 3. Symbol Selection:
    ///    - If valid `forcedSymbols` are provided (QA / Development mode), uses them directly.
    ///    - Otherwise, samples 3 symbols independently via weighted probability (`SlotSymbol.randomWeighted()`).
    /// 4. Payline Evaluation: Checks if symbols[0] == symbols[1] == symbols[2].
    /// 5. Win Computation: Computes `winAmount = currentBet * payout`.
    /// 6. Balance & Stats Update: If winning, adds `winAmount` back to credits and updates `biggestWin` and `totalWinnings`.
    /// 7. Persistence: Synchronizes updated state to `UserDefaults` via `StorePreference`.
    ///
    /// - Parameter forcedSymbols: Optional array of 3 symbols to force specific outcomes for testing.
    /// - Returns: Fully resolved `SpinResult` containing symbols, win flag, payout multiplier, and total credits won.
    func spin(forcedSymbols: [SlotSymbol]? = nil) -> SpinResult {
        // 1. Guard against insufficient credits
        guard canSpin() else {
            return SpinResult(symbols: [], isWin: false, payout: 0, winAmount: 0)
        }

        // 2. Deduct bet amount and record spin count
        state.credits -= state.currentBet
        state.totalSpins += 1

        // 3. Determine outcome symbols (Dev test injection or weighted RNG)
        let resultSymbols: [SlotSymbol]
        if let forced = forcedSymbols, forced.count == 3 {
            resultSymbols = forced
        } else {
            resultSymbols = (0..<3).map { _ in SlotSymbol.randomWeighted() }
        }

        // 4. Evaluate payline for matching 3-of-a-kind
        let (isWin, payout) = evaluateWin(resultSymbols)
        let winAmount = isWin ? state.currentBet * payout : 0

        // 5. Update game economy and lifetime records upon winning
        if isWin {
            state.credits += winAmount
            state.totalWinnings += winAmount
            if winAmount > state.biggestWin {
                state.biggestWin = winAmount
            }
        }

        // 6. Persist updated game state to storage
        preferences.saveGameState(state)

        return SpinResult(
            symbols: resultSymbols,
            isWin: isWin,
            payout: payout,
            winAmount: winAmount
        )
    }

    /// Evaluates whether the given symbols form a winning 3-of-a-kind payline.
    /// - Parameter symbols: Array of 3 symbols settled on the center payline.
    /// - Returns: A tuple containing a boolean `isWin` flag and the corresponding `payout` multiplier.
    private func evaluateWin(_ symbols: [SlotSymbol]) -> (Bool, Int) {
        guard symbols.count == 3 else { return (false, 0) }

        if symbols[0] == symbols[1] && symbols[1] == symbols[2] {
            return (true, symbols[0].payout)
        }
        return (false, 0)
    }

    // MARK: - Game State Reset Process

    /// Resets all player credits, bets, and lifetime statistics back to their initial defaults,
    /// clearing persisted preferences in `UserDefaults`.
    func resetGame() {
        state.reset()
        preferences.reset()
    }
}
