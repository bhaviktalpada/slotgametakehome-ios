# Symbol Assets

Some PNG symbols are provided for a professional slot machine appearance:

## PNG Symbol Set

### cherry.png
- **Payout**: 2x bet
- **Theme**: Classic fruit symbol
- **Rarity**: Common
- **Size**: 300x300px

### lemon.png
- **Payout**: 3x bet
- **Theme**: Classic fruit symbol
- **Rarity**: Common
- **Size**: 300x300px

### seven.png
- **Payout**: 5x bet
- **Theme**: Classic slot number
- **Rarity**: Uncommon
- **Size**: 300x300px

### bell.png
- **Payout**: 10x bet
- **Theme**: Traditional slot symbol
- **Rarity**: Uncommon
- **Size**: 300x300px

### star.png
- **Payout**: 15x bet
- **Theme**: Premium symbol
- **Rarity**: Rare
- **Size**: 300x300px

### diamond.png
- **Payout**: 25x bet
- **Theme**: Jackpot symbol
- **Rarity**: Very Rare
- **Size**: 300x300px

## Implementation Example

```swift
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
}

// Usage Example:
let symbolImage = UIImage(named: SlotSymbol.cherry.imageName)
```

## Asset Specifications
- **Format**: PNG with transparency
- **Size**: 300x300px (single resolution)
- **Display size on iPad**: Scale to fit reel slots (approximately 64x64pt)
- **Naming convention**: symbol.png (e.g., cherry.png, lemon.png)
- **Quality**: High-resolution source that iOS will scale automatically