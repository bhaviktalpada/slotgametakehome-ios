# Slot Game Take-Home - iOS

A fully functional iOS slot machine game built for iPad in landscape orientation.

## Features Implemented

### Core Features
- **3 Spinning Reels** - Smooth spinning animation with realistic slot machine feel
- **Play Button** - Triggers spin with bet deduction
- **Credits Balance** - Starts at 100 credits, updates in real-time
- **Bet Selector** - 1, 5, 10 credits per spin via segmented control
- **Win Detection** - 3 matching symbols = win with different payout multipliers
- **Balance Management** - Deducts bet on spin, adds winnings, prevents spin when insufficient credits

### Payout Table
- Cherry-Cherry-Cherry = 2x bet
- Lemon-Lemon-Lemon = 3x bet
- Seven-Seven-Seven = 5x bet
- Bell-Bell-Bell = 10x bet
- Star-Star-Star = 15x bet
- Diamond-Diamond-Diamond = 25x bet

### Bonus Features
- **Win Animation** - Flash effect on reels and overlay when winning
- **Statistics Tracking** - Total spins, biggest win, total winnings displayed
- **Weighted Random Symbols** - Common symbols (cherry, lemon) appear more frequently than rare ones (diamond)
- **iPad Landscape Only** - Optimized for landscape orientation gaming experience

## Architecture

```
Models/
├── SlotSymbol.swift      - Symbol enum with payouts, weights, and random selection
└── GameEngine.swift      - Game logic, spin mechanics, win evaluation, state management

Views/
├── SlotReelView.swift    - Custom UIView for individual reel with spinning animation
└── GameViewController.swift - Main game UI and controller
```

## Technical Details

- **Language**: Swift 5
- **Framework**: UIKit
- **Minimum iOS**: 15.0
- **Target Device**: iPad (landscape only)
- **Design Pattern**: MVC with clean separation of concerns
- **Animation**: Timer-based spinning with UIView transitions

## Asset Usage

Uses provided assets from `/Assets` folder:
- 6 custom PNG symbols (cherry, lemon, seven, bell, star, diamond) at 300x300px
- Background images (reels-background, reels-background-only, reels-example)
- Play button asset
- Color palette: Dark theme with gold accent (#ffd700)

## How to Run

1. Open `slotgametakehome.xcodeproj` in Xcode
2. Select iPad simulator (e.g., "iPad (A16)")
3. Build and run (⌘+R)
4. App launches in landscape orientation

## Gameplay

1. App starts with 100 credits
2. Select bet amount (1, 5, or 10 credits)
3. Tap SPIN to play
4. Reels spin and stop on random symbols
5. Match 3 symbols to win based on payout table
6. Credits update automatically
7. Game prevents spinning when credits < bet amount

## What Could Be Improved

- Add sound effects for spinning and winning
- Implement auto-spin functionality
- Add haptic feedback on spin/win
- Create more elaborate win animations (particle effects)
- Add persistence for credits across app launches
- Implement jackpot feature for rare combinations
- Add settings for bet limits and sound toggles

## Project Structure

```
slotgametakehome-ios/
├── slotgametakehome/
│   ├── Models/
│   │   ├── SlotSymbol.swift
│   │   └── GameEngine.swift
│   ├── Views/
│   │   ├── SlotReelView.swift
│   │   └── GameViewController.swift
│   ├── Assets.xcassets/
│   │   ├── Symbol images (cherry, lemon, seven, bell, star, diamond)
│   │   ├── Background images
│   │   └── App icons
│   ├── Base.lproj/
│   │   └── LaunchScreen.storyboard
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
├── Assets/ (source assets)
└── README.md
```

## Notes

- Code is written in a clean, human style following iOS best practices
- No storyboards used for main UI - all programmatic for flexibility
- Proper memory management with weak delegates
- Edge cases handled (insufficient balance, rapid taps prevented)
- Extensible design for future features