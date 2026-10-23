# Slot Game Take-Home - iOS (iPad Only)

A fully functional, arcade-style iOS slot machine game built exclusively for **iPad in landscape orientation**, designed to scale across all iPad screen sizes.

---

## Highlights & Features Implemented

### Core Features
- **Full-Screen Arcade Experience**:
  - The vintage marquee cabinet background (`reels-background-only`) fills the screen edge-to-edge across all iPad sizes without black letterbox borders.
- **Alternating Column Spin Directions**:
  - **Column 1**: Moves from **Top to Bottom** (downward)
  - **Column 2**: Moves from **Bottom to Top** (upward)
  - **Column 3**: Moves from **Top to Bottom** (downward)
- **Soft Scrolling Speed & Deceleration**:
  - Spins at high speed initially, then smoothly decelerates to low speed using a progressive cubic ease-out curve before an authentic mechanical spring settle into the final symbol.
  - Realistic **staggered reel stops** (Reel 1 stops first, followed sequentially by Reel 2 and Reel 3) to build suspense.
- **Development & Testing Environment (`DEV` / `PROD`)**:
  - **Environment Toggle**: Switch between **Development Mode** (`DEV`) and **Production Mode** (`PROD`).
  - **Predefined Outcome Selector**: When in Development mode, an interactive dropdown menu allows selecting predefined spin outcomes for testing:
    - 🎲 **Random** (Standard game RNG)
    - 🍒 **Cherry Win** (3x Cherry)
    - 🍋 **Lemon Win** (3x Lemon)
    - 7️⃣ **Seven Win** (3x Seven)
    - 🔔 **Bell Win** (3x Bell)
    - ⭐ **Star Win** (3x Star)
    - 💎 **Diamond Win** (3x Diamond)
    - ❌ **Guaranteed Loss**
  - In **Production Mode**, test options are hidden.
- **Payline Evaluation & Win Detection**:
  - Evaluates matching 3-of-a-kind on the center payline.
  - Full payout multiplier table:
    - **Cherry 🍒**: 2x bet
    - **Lemon 🍋**: 3x bet
    - **Seven 7️⃣**: 5x bet
    - **Bell 🔔**: 10x bet
    - **Star ⭐**: 15x bet
    - **Diamond 💎**: 25x bet (Jackpot)
- **Lottie Win Celebration Animation**:
  - Superimposes a dynamic **Lottie celebration animation** (`animation_win.json`) directly on top of the reels view whenever any winning combination is hit.
  - Non-blocking (`isUserInteractionEnabled = false`) with graceful auto-fade upon completion or when a new spin begins.
- **Credits, Score & Statistics Persistence (`StorePreference`)**:
  - Stores player credits balance, highest win, total spins, and total winnings in `UserDefaults` via `StorePreference`.
  - Persists state seamlessly across app launches and restarts.
  - Starting balance of **100 credits** on fresh install.
  - Bet selector for **1, 5, or 10 credits** via styled segmented control.
  - Automatic balance deduction on spin and animated credit roll-up on winnings.
  - Disables spin and alerts player with tactile/visual shake feedback if credits are insufficient.
- **Audio & Sound Effects**:
  - Plays `"spinning-sound.wav"` exactly **once per spin** via `SoundManager` (`numberOfLoops = 0`).
  - Configured with `AVAudioSession` `.ambient` mode for background music compatibility.
- **Properly Aligned Controls & UI Hierarchy**:
  - Polished Auto Layout hierarchy ensuring the **SPIN** button and game statistics labels never overlap on any iPad screen size.
- **Statistics Tracking**:
  - Real-time display of **Total Spins**, **Biggest Win**, and **Total Won**.

---

## Configuration File (`GameConfig.swift`)

All key game parameters, animation timings, audio filenames, and economy values are declared in `Models/GameConfig.swift` for easy customization:

```swift
enum GameConfig {
    // MARK: - Audio Configuration
    /// The sound file played during reel spinning.
    static let soundFileName: String = "spinning-sound.wav"

    // MARK: - Animation Timings (in seconds)
    /// Base duration for the first reel to spin.
    static let baseSpinDuration: TimeInterval = 2.8

    /// Delay between consecutive reel stops (creates staggered mechanical stops).
    static let reelStaggerDelay: TimeInterval = 0.35

    /// Interval between symbol transitions during spinning.
    static let spinStepInterval: TimeInterval = 0.05

    /// Duration of the winning symbols pulse/celebration animation.
    static let winAnimationDuration: TimeInterval = 0.7

    /// Duration for result and status label spring transitions.
    static let resultAnimationDuration: TimeInterval = 0.35

    // MARK: - Game Economy
    /// Initial balance of credits.
    static let initialCredits: Int = 100

    /// Available bet denominations.
    static let betOptions: [Int] = [1, 5, 10]

    /// Default selected bet amount.
    static let defaultBet: Int = 1
}
```

---

## iPad Landscape Orientation & Universal Multi-Size Support

The app is strictly built for **iPad in Landscape orientation**:

1. **Orientation Enforcement**:
   - `TARGETED_DEVICE_FAMILY = 2` (iPad only).
   - `UISupportedInterfaceOrientations~ipad`: `UIInterfaceOrientationLandscapeLeft`, `UIInterfaceOrientationLandscapeRight`.
   - `AppDelegate` and `GameViewController` enforce `.landscape`.
   - Removed fixed 1024x768 window restrictions in `SceneDelegate` to unlock native resolutions.
2. **Dynamic Proportional Scaling**:
   - The arcade marquee cabinet (`reels-background-only.png`) has a 1.5:1 aspect ratio.
   - Centered inside `safeAreaLayoutGuide` with flexible priority-based constraints (`width <= 96% safeArea`, `height <= 93% safeArea`, maintaining `1536 / 1024` aspect ratio).
   - Works seamlessly across all iPad models:
     - **iPad mini** (8.3")
     - **iPad 10.2" & 10.9"**
     - **iPad Air 11" & 13"**
     - **iPad Pro 11" & 12.9" / 13"**

---

## Architecture & Code Structure

Follows the classic **MVC (Model-View-Controller)** pattern with clean separation of concerns and human-written idiomatic Swift:

```
slotgametakehome/
├── Models/
│   ├── GameConfig.swift        - Centralized animation times, sound name, and economy config
│   ├── SlotSymbol.swift        - Symbol enumeration, payouts, weights, and image loading
│   └── GameEngine.swift        - Game state, credit management, win evaluation, testable spin logic
├── Services/
│   ├── StorePreference.swift   - UserDefaults persistence for player score, credits, and stats
│   └── SoundManager.swift      - Audio session and single-shot sound effect playback, haptics
├── Views/
│   ├── SlotReelView.swift      - Custom reel column with soft deceleration physics & spring settle
│   └── GameViewController.swift - Main game screen coordinating cabinet, reels, UI, and animations
├── Assets.xcassets/             - Symbol PNGs, background marquee graphics, app icons
├── Resoureces/
│   └── spinning-sound.wav      - Audio asset bundled with target
├── AppDelegate.swift           - Application lifecycle & orientation policy
├── SceneDelegate.swift         - UIWindowScene lifecycle
└── Info.plist                  - Target settings & landscape constraints
```

---

## Payout Table

| Symbol | Matching Count | Multiplier | Rarity Weight |
|:---:|:---:|:---:|:---:|
| 🍒 Cherry | 3 | **2x Bet** | Common (30) |
| 🍋 Lemon | 3 | **3x Bet** | Common (30) |
| 7️⃣ Seven | 3 | **5x Bet** | Medium (20) |
| 🔔 Bell | 3 | **10x Bet** | Medium (20) |
| ⭐ Star | 3 | **15x Bet** | Rare (15) |
| 💎 Diamond | 3 | **25x Bet** | Jackpot (5) |

---

## How to Run & Test

### Running the App
1. Open `slotgametakehome.xcodeproj` in Xcode.
2. Select any iPad simulator in the run destination (e.g., *iPad (A16)*, *iPad Pro 11-inch*, or *iPad Pro 13-inch*).
3. Build and Run (**⌘R**). The app will automatically launch in landscape mode.

### Running Unit Tests
- In Xcode, press **⌘U**, or run from terminal:
  ```bash
  xcodebuild test -project slotgametakehome.xcodeproj -scheme slotgametakehome -destination 'platform=iOS Simulator,name=iPad (A16)'
  ```
- Unit tests cover:
  - Configuration verification (`GameConfig.soundFileName`, animation times)
  - Balance and bet validation
  - Win calculations and payouts for every symbol
  - Edge cases (insufficient credits prevention)
  - Game statistics tracking and state reset