import Foundation

struct SpinResult {
    let symbols: [SlotSymbol]
    let isWin: Bool
    let payout: Int
    let winAmount: Int

    var winningSymbol: SlotSymbol? {
        guard isWin else { return nil }
        return symbols.first
    }
}

struct GameState {
    var credits: Int = 100
    var currentBet: Int = 1
    var totalSpins: Int = 0
    var biggestWin: Int = 0
    var totalWinnings: Int = 0

    mutating func reset() {
        credits = 100
        currentBet = 1
        totalSpins = 0
        biggestWin = 0
        totalWinnings = 0
    }
}

final class GameEngine {
    private let symbols: [SlotSymbol] = SlotSymbol.allCases
    private var state = GameState()

    var currentState: GameState {
        return state
    }

    func canSpin() -> Bool {
        return state.credits >= state.currentBet
    }

    func setBet(_ bet: Int) {
        state.currentBet = bet
    }

    func spin() -> SpinResult {
        guard canSpin() else {
            return SpinResult(symbols: [], isWin: false, payout: 0, winAmount: 0)
        }

        state.credits -= state.currentBet
        state.totalSpins += 1

        let resultSymbols = (0..<3).map { _ in SlotSymbol.randomWeighted() }
        let (isWin, payout) = evaluateWin(resultSymbols)
        let winAmount = isWin ? state.currentBet * payout : 0

        if isWin {
            state.credits += winAmount
            state.totalWinnings += winAmount
            if winAmount > state.biggestWin {
                state.biggestWin = winAmount
            }
        }

        return SpinResult(
            symbols: resultSymbols,
            isWin: isWin,
            payout: payout,
            winAmount: winAmount
        )
    }

    private func evaluateWin(_ symbols: [SlotSymbol]) -> (Bool, Int) {
        guard symbols.count == 3 else { return (false, 0) }

        if symbols[0] == symbols[1] && symbols[1] == symbols[2] {
            return (true, symbols[0].payout)
        }
        return (false, 0)
    }

    func resetGame() {
        state.reset()
    }
}