import Foundation
import UIKit

enum SlotSymbol: String, CaseIterable {
    case cherry = "cherry"
    case lemon = "lemon"
    case seven = "seven"
    case bell = "bell"
    case star = "star"
    case diamond = "diamond"

    var imageName: String {
        return self.rawValue
    }

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

    var weight: Int {
        switch self {
        case .cherry, .lemon: return 30
        case .seven, .bell: return 20
        case .star: return 15
        case .diamond: return 5
        }
    }

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

extension SlotSymbol {
    var image: UIImage? {
        return UIImage(named: imageName)
    }
}