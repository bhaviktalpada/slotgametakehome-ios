# Starter Assets for iOS Slot Game

This folder contains basic visual assets that candidates can use to accelerate their development. **These assets are completely optional** - candidates are free to create their own designs or use these as a starting point.

## Included Assets

### Background Images
- `slot-background.svg` - Main game background with reel areas
- `reel-frame.svg` - Individual reel frame/border

### Symbol Assets (Custom PNG files)
Professional slot machine symbols provided:
- cherry.png - Classic fruit symbol (300x300px)
- lemon.png - Classic fruit symbol (300x300px)
- seven.png - Traditional slot number (300x300px)
- bell.png - Classic slot symbol (300x300px)
- star.png - Premium symbol (300x300px)
- diamond.png - Jackpot symbol (300x300px)

All symbols provided as high-resolution 300x300px PNG files.

### Color Palette
```
Primary Background: #1a1a2e
Secondary Background: #16213e
Accent Gold: #ffd700
Accent Red: #e94560
Success Green: #0f3460
Text White: #ffffff
```

## Usage Instructions

### For Candidates
1. **Optional Use**: You can use these assets or create your own
2. **Import**: Drag assets into your Xcode project
3. **Customize**: Feel free to modify colors, sizes, or replace entirely
4. **Focus**: Spend your time on code logic rather than asset creation

### Asset Details

#### slot-background.svg
- Dimensions: 1024x768 (iPad landscape)
- Contains 3 large reel areas positioned for easy integration
- Dark theme design for modern slot machine look
- Optimized for landscape orientation gaming experience

#### reel-frame.svg  
- Individual reel border/frame (160x270px)
- Can be overlaid on reel content
- Gives professional slot machine appearance
- Sized for larger iPad symbols and better visibility

## Implementation Tips

### Using in UIKit
```swift
// Background image
let backgroundImageView = UIImageView(image: UIImage(named: "slot-background"))

// Reel frames
let reelFrame = UIImageView(image: UIImage(named: "reel-frame"))

// Symbol images
let cherrySymbol = UIImageView(image: UIImage(named: "cherry"))
```

### Using in SwiftUI
```swift
// Background
Image("slot-background")
    .resizable()
    .ignoresSafeArea()

// Reel frame with symbol
Image("reel-frame")
    .overlay(
        Image("cherry")
            .resizable()
            .aspectRatio(contentMode: .fit)
    )
```

### Symbol Loading
```swift
// Load symbol by name
func loadSymbol(_ symbolName: String) -> UIImage? {
    return UIImage(named: symbolName)
}

// Using the SlotSymbol enum
let symbolImage = UIImage(named: SlotSymbol.cherry.imageName)

// For animations, preload all symbols
let symbolImages = SlotSymbol.allCases.compactMap { 
    UIImage(named: $0.imageName) 
}

// Scale images for display (300x300px -> desired size)
func scaleSymbolImage(_ image: UIImage, to size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    image.draw(in: CGRect(origin: .zero, size: size))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return scaledImage
}
```

## Notes
- All assets are provided in vector format (SVG) for scalability
- Color scheme is designed to be casino/slot machine themed
- Simple, clean design that won't distract from code evaluation
- Candidates should focus on functionality over visual perfection