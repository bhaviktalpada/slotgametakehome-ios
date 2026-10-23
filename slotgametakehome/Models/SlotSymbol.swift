//
//  SlotSymbol.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.
//

import UIKit

enum SlotSymbol: String, CaseIterable {
    case cherry
    case lemon
    case seven
    case bell
    case star
    case diamond

    var imageName: String {
        rawValue
    }

    // 3-of-a-kind payout multipliers
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

    // Probability weights (higher = more frequent, diamond is jackpot)
    var weight: Int {
        switch self {
        case .cherry, .lemon: return 30
        case .seven, .bell: return 20
        case .star: return 15
        case .diamond: return 5
        }
    }

    var image: UIImage? {
        UIImage(named: imageName)
    }

    // Weighted random roll so high payouts stay rare
    static func randomWeighted() -> SlotSymbol {
        let totalWeight = allCases.reduce(0) { $0 + $1.weight }
        let roll = Int.random(in: 1...totalWeight)

        var accumulated = 0
        for symbol in allCases {
            accumulated += symbol.weight
            if roll <= accumulated {
                return symbol
            }
        }
        return .cherry
    }
}
