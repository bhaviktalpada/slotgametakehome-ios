//
//  SlotSymbol.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.

import Foundation
import UIKit

/// Enumeration of all slot machine symbols with their asset names, payout multipliers, and probability weights.
enum SlotSymbol: String, CaseIterable {
    case cherry = "cherry"
    case lemon = "lemon"
    case seven = "seven"
    case bell = "bell"
    case star = "star"
    case diamond = "diamond"

    // MARK: - Asset Naming

    /// The name of the corresponding image asset in Assets.xcassets.
    var imageName: String {
        return self.rawValue
    }

    // MARK: - Payout Multipliers

    /// Payout multiplier awarded when 3 matching symbols appear on the center payline.
    /// Multiplied by current bet: `winAmount = currentBet * payout`.
    var payout: Int {
        switch self {
        case .cherry: return 2
        case .lemon: return 3
        case .seven: return 5
        case .bell: return 10
        case .star: return 15
        case .diamond: return 25
        }
    }

    // MARK: - Probability Weights

    /// Relative likelihood of this symbol being selected during standard random spins.
    /// Higher values indicate higher frequency (common), lower values indicate lower frequency (rare/jackpot).
    /// - Cherry & Lemon: Weight 30 (~25% each)
    /// - Seven & Bell: Weight 20 (~16.7% each)
    /// - Star: Weight 15 (~12.5%)
    /// - Diamond: Weight 5 (~4.2% - Jackpot)
    var weight: Int {
        switch self {
        case .cherry, .lemon: return 30
        case .seven, .bell: return 20
        case .star: return 15
        case .diamond: return 5
        }
    }

    // MARK: - Weighted Random Sampling Process

    /// Selects a random symbol according to the relative probability weights defined above.
    /// - Process:
    ///   1. Sums the weights of all symbol cases to determine the total weight ceiling.
    ///   2. Generates a random integer in the range `1...totalWeight`.
    ///   3. Accumulates weights sequentially until the random threshold is reached.
    ///   4. Returns the matching symbol, ensuring authentic casino rarity distributions.
    /// - Returns: A randomly selected `SlotSymbol` based on weight distribution.
    static func randomWeighted() -> SlotSymbol {
        let totalWeight = SlotSymbol.allCases.reduce(0) { $0 + $1.weight }
        let randomValue = Int.random(in: 1...totalWeight)

        var cumulativeWeight = 0
        for symbol in SlotSymbol.allCases {
            cumulativeWeight += symbol.weight
            if randomValue <= cumulativeWeight {
                return symbol
            }
        }
        return .cherry
    }
}

// MARK: - UIImage Loading Extension

extension SlotSymbol {
    /// Loads the `UIImage` asset associated with this symbol from the bundle.
    var image: UIImage? {
        return UIImage(named: imageName)
    }
}
