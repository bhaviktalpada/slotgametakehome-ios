# Slot Game - iOS (iPad Only)

An arcade-style slot machine game built with Swift and UIKit exclusively for iPad in landscape orientation.

---

## Overview & Approach

My goal for this project was to build a polished, tactile slot machine that feels like a physical arcade cabinet while keeping the codebase clean, modular, and easy to test.

I followed standard **MVC architecture**:

- **Models (`GameEngine`, `SlotSymbol`, `GameConfig`)**: Encapsulate the core game rules, payout calculations, probability weights, and session state. The engine has zero UI dependencies and is fully covered by unit tests.
- **Views (`SlotReelView`)**: Custom view representing a 3-row vertical reel column. It handles directional scrolling transitions, deceleration physics, and the spring bounce settle.
- **Controllers (`GameViewController`)**: Wires up the cabinet interface, user actions, animated credit roll-up, and Lottie win celebration overlays.
- **Services (`StorePreference`, `SoundManager`)**: Clean singletons managing `UserDefaults` persistence and single-shot AVFoundation audio + haptic feedback.

---

## Features

### 1. iPad Landscape & Responsive Layout

- Locked exclusively to landscape on iPad (`TARGETED_DEVICE_FAMILY = 2`, `requestGeometryUpdate`).
- The vintage cabinet background fills edge-to-edge across all iPad sizes (iPad mini, 10.2", 10.9", Air, Pro 11"/13").
- Content is anchored to layout guides set just inside the illuminated frame bulbs, so controls never overlap the cabinet graphics.

### 2. Alternating Reel Directions

- **Reel 1**: Scrolls downward (top to bottom).
- **Reel 2**: Scrolls upward (bottom to top).
- **Reel 3**: Scrolls downward (top to bottom).
- Implemented with Core Animation push transitions (`CATransition`) for crisp 60fps symbol shifting.

### 3. Smooth Deceleration Physics

- The spin starts fast (0.04s per frame) for excitement, then follows a cubic ease-out slowdown in the second half.
- Each reel stops sequentially (0.35s delay between reels) to build anticipation.
- When stopping, each reel overshoots slightly in its scroll direction (+8pt down or -8pt up) and springs back via `UIView.animate(usingSpringWithDamping: 0.68)`.

### 4. Game Economy & Win Logic

- Starting balance of 100 credits.
- Bet denominations of 1, 5, or 10 credits via custom segmented control.
- Balance deducts immediately on spin and rolls up with an animated counter when winning.
- Tapping SPIN with insufficient credits triggers a shake animation and warning.

### 5. Lottie Celebration & Win Effects

- Winning payline symbols glow gold with a pulsing scale animation.
- A Lottie celebration overlay (`animation_win.json`) plays directly over the reels and auto-fades when finished or when the next spin begins.

### 6. Development Mode & Test Result Picker

- A small HUD in the top left toggles between **DEV** and **PROD** mode.
- In **DEV** mode, a dropdown menu allows forcing specific outcomes (e.g. 3x Cherry, 3x Diamond Jackpot, Guaranteed Loss) for testing payouts and animations without relying on RNG.
- In **PROD** mode, the test HUD is completely hidden.

### 7. Sound, Haptics & Persistence

- Single-shot spin audio (`spinning-sound.wav`) plays once per spin on an `.ambient` AVAudioSession so background music is not interrupted.
- Mechanical haptics on button tap, reel stop clunk, and win success.
- Credits, highest win, total spins, and last bet persist across launches using `UserDefaults` via `StorePreference`.

---

## Payout Table

Matching 3 symbols on the center payline awards:

| Symbol     | Multiplier | Payout (Bet 1) | Payout (Bet 5) | Payout (Bet 10) | Frequency      |
| ---------- | ---------- | -------------- | -------------- | --------------- | -------------- |
| 🍒 Cherry  | 2x         | 2              | 10             | 20              | Common (25%)   |
| 🍋 Lemon   | 3x         | 3              | 15             | 30              | Common (25%)   |
| 7️⃣ Seven   | 5x         | 5              | 25             | 50              | Medium (16.7%) |
| 🔔 Bell    | 10x        | 10             | 50             | 100             | Medium (16.7%) |
| ⭐ Star    | 15x        | 15             | 75             | 150             | Rare (12.5%)   |
| 💎 Diamond | 25x        | 25             | 125            | 250             | Jackpot (4.2%) |

---

## Visual Assets & Centralized Theme Styling

The app uses custom high-resolution artwork and a dedicated color theming system:

### 1. Visual & Audio Assets

- **Background (`slot-background`)**: High-resolution vintage arcade marquee sized for iPad landscape (1024x768 and scalable up to 13" iPad Pro).
- **Reel Frames (`reel-frame`)**: Beveled metallic border frames housing the three vertical reels.
- **Symbol Assets (300x300px)**:
  - 🍒 `cherry` - Classic fruit symbol
  - 🍋 `lemon` - Traditional citrus symbol
  - 7️⃣ `seven` - Lucky slot number
  - 🔔 `bell` - Classic mechanical slot bell
  - ⭐ `star` - Premium celestial symbol
  - 💎 `diamond` - Top-tier jackpot gemstone
- **Audio Asset (`spinning-sound.wav`)**: Clean mechanical clicker sound played as a single-shot audio session on `.ambient` category.
- **Celebration Asset (`animation_win.json`)**: Vector Lottie particle burst played over the reels on winning spins.

### 2. Centralized Color Palette (`ThemeColor.swift`)

All colors across the codebase are centralized in [ThemeColor.swift](file:///Users/Mackbook/Github/iOS/slotgametakehome-ios/slotgametakehome/Services/ThemeColor.swift) with optional, independent `alpha` parameter support:

```swift
ThemeColor.arcadeBackground(alpha:)     // Deep charcoal arcade backdrop
ThemeColor.gold(alpha:)                 // Vibrant payout & border highlight
ThemeColor.orangeGlow(alpha:)           // Warm marquee glow
ThemeColor.reelBackground(alpha:)       // Inset reel column backing
ThemeColor.reelBorder(alpha:)           // Mechanical reel separators
ThemeColor.controlBackground(alpha:)    // Semi-translucent button backgrounds
ThemeColor.devBackground(alpha:)        // QA HUD drawer backing
ThemeColor.devBorder(alpha:)            // QA HUD outline
ThemeColor.devBadgeGreen(alpha:)        // Active DEV status pill
ThemeColor.prodBadgeGray(alpha:)        // Inactive PROD status pill
ThemeColor.testButtonBackground(alpha:) // Dropdown menu selector button
ThemeColor.winGreen(alpha:)             // Payout success banner
ThemeColor.lossRed(alpha:)              // Balance depletion warning
ThemeColor.statsText(alpha:)            // High-contrast HUD readout
ThemeColor.disabledText(alpha:)         // Dimmed inactive labels
```

---

## Project Structure

```
slotgametakehome/
├── Models/
│   ├── GameConfig.swift        // Global timings, sound name, and economy config
│   ├── SlotSymbol.swift        // Symbols enum, multipliers, weights, and image loading
│   └── GameEngine.swift        // Bet validation, spin logic, and win evaluation
├── Services/
│   ├── ThemeColor.swift        // Centralized color theme with configurable alpha
│   ├── StorePreference.swift   // UserDefaults storage for score and stats
│   └── SoundManager.swift      // Single-shot audio playback and haptics
├── Views/
│   ├── SlotReelView.swift      // Custom reel with alternating push and spring bounce
│   └── GameViewController.swift // Main screen coordinating layout, spins, and overlays
├── Assets.xcassets/            // PNG symbols and background marquee graphics
├── Resoureces/
│   ├── spinning-sound.wav      // Sound effect asset
│   └── animation_win.json      // Lottie animation file
├── AppDelegate.swift
└── SceneDelegate.swift
```

---

## Configuration File (`GameConfig.swift`)

All core constants, audio asset names, animation durations, and environment controls are centralized in [GameConfig.swift](file:///Users/Mackbook/Github/iOS/slotgametakehome-ios/slotgametakehome/Models/GameConfig.swift):

```swift
enum GameConfig {
    // Environment Mode: .development exposes QA Test HUD; .production hides it
    static var environment: AppEnvironment = .development
    static var selectedTestOption: PredefinedSpinOption = .random

    // Sound file name in bundle
    static let soundFileName = "spinning-sound.wav"

    // Animation & Reel Timings (in seconds)
    static var baseSpinDuration: TimeInterval = 2.8      // Duration of Reel 1
    static let reelStaggerDelay: TimeInterval = 0.35     // Delay before subsequent reels stop
    static let spinStepInterval: TimeInterval = 0.04     // Symbol transition interval at top speed
    static let winAnimationDuration: TimeInterval = 0.7  // Win highlight pulse duration
    static let resultAnimationDuration: TimeInterval = 0.35 // Win/loss popup spring duration

    // Game Economy
    static let initialCredits: Int = 100                 // Starting player balance
    static let betOptions: [Int] = [1, 5, 10]            // Available bet amounts
    static let defaultBet: Int = 1                       // Initial bet
}
```

### Parameter Breakdown:

- **`environment` & `selectedTestOption`**: Toggles between DEV (shows the test picker HUD to force specific combinations) and PROD (standard player experience).
- **`soundFileName`**: Bundle name for single-shot spinning audio (`spinning-sound.wav`).
- **`baseSpinDuration` (2.8s)**: Total spinning time for the first reel before it initiates its spring settle.
- **`reelStaggerDelay` (0.35s)**: Incremental stop delay per subsequent reel column (Reel 1: 2.80s, Reel 2: 3.15s, Reel 3: 3.50s) to build mechanical suspense.
- **`spinStepInterval` (0.04s)**: High-speed symbol transition interval during continuous spin.
- **`initialCredits` (100)** & **`betOptions` ([1, 5, 10])**: Default wallet balance and selectable stakes.

---

## Spin Execution & Result Calculation Logic

The lifecycle of each spin flows through four coordinated stages across the codebase:

```
[User Taps SPIN]
       │
       ▼
GameViewController.spinTapped()
       │
       ▼
GameEngine.spin(forcedSymbols:)
       ├─► Deducts currentBet from credits
       ├─► Rolls 3 symbols via SlotSymbol.randomWeighted() (or uses DEV forced outcome)
       ├─► Evaluates 3-of-a-kind payline via GameEngine.evaluateWin()
       ├─► Calculates winAmount = bet * payout
       └─► Persists state via StorePreference.shared.saveGameState()
       │
       ▼
SlotReelView.spin(to:duration:completion:)
       ├─► Dispatches staggered spins (Reel 1: 2.8s, Reel 2: 3.15s, Reel 3: 3.50s)
       ├─► Applies alternating push directions: Reel 0 (down), Reel 1 (up), Reel 2 (down)
       ├─► Decelerates with cubic ease-out curve in the final 45% of spin
       └─► Overshoots (+/-8pt) and snaps back via spring bounce animation
       │
       ▼
GameViewController.handleAllReelsStopped()
       ├─► If WIN: triggers haptic, pulses gold border, plays Lottie celebration, rolls up credits
       └─► If LOSS: displays try again notice, re-enables controls
```

### 1. User Taps Spin

- **Class**: `GameViewController`
- **Method**: `@objc private func spinTapped()`
- **Responsibilities**:
  1. Calls `gameEngine.canSpin()` to verify `credits >= currentBet`. If insufficient, triggers `showInsufficientCreditsNotice()` with an error shake on the credits counter.
  2. Sets `isSpinning = true`, disables the SPIN button (alpha dimmed to 0.45), and disables the bet segmented control to prevent concurrent spins.
  3. Plays single-shot audio via `SoundManager.shared.playSpinSound()` and fires haptic feedback via `SoundManager.shared.playSpinStartFeedback()`.
  4. Reads `GameConfig.selectedTestOption.forcedSymbols` (if in DEV mode) or passes `nil` for organic RNG.
  5. Calls `gameEngine.spin(forcedSymbols:)` to compute the outcome immediately.
  6. Updates the credits display to reflect the deducted wager upfront: `creditsAfterBet = credits - (isWin ? winAmount : 0)`.
  7. Dispatches staggered spin animations to each of the 3 `SlotReelView` columns.

### 2. Result & Payout Calculation

- **Class**: `GameEngine`
- **Methods**: `spin(forcedSymbols:)` and `evaluateWin(_:)`
- **Calculations**:
  1. **Deduct Wager**:
     ```swift
     state.credits -= state.currentBet
     state.totalSpins += 1
     ```
  2. **Roll Symbols**:
     - In DEV mode with a selected test case: uses the pre-selected symbols.
     - In standard mode: rolls 3 symbols independently via `SlotSymbol.randomWeighted()`.
  3. **Weighted RNG Roll (`SlotSymbol.randomWeighted()` in `SlotSymbol.swift`)**:
     Symbols have probability weights (Cherry: 30, Lemon: 30, Seven: 20, Bell: 20, Star: 15, Diamond: 5). Total weight = 120.
     The algorithm rolls `Int.random(in: 1...totalWeight)` and traverses cumulative weight bounds:
     - 🍒 Cherry: ~25.0%
     - 🍋 Lemon: ~25.0%
     - 7️⃣ Seven: ~16.7%
     - 🔔 Bell: ~16.7%
     - ⭐ Star: ~12.5%
     - 💎 Diamond: ~4.2%
  4. **Payline Evaluation (`evaluateWin(_:)`)**:
     Tests whether all three symbols on the center row match:
     ```swift
     if symbols[0] == symbols[1] && symbols[1] == symbols[2] {
         return (true, symbols[0].payout)
     }
     return (false, 0)
     ```
  5. **Win Amount & Multiplier**:
     $$\text{winAmount} = \begin{cases} \text{currentBet} \times \text{payoutMultiplier} & \text{if } 3\text{ matching symbols} \\ 0 & \text{otherwise} \end{cases}$$
     - 🍒 Cherry: 2x bet
     - 🍋 Lemon: 3x bet
     - 7️⃣ Seven: 5x bet
     - 🔔 Bell: 10x bet
     - ⭐ Star: 15x bet
     - 💎 Diamond: 25x bet (Jackpot)
  6. **Wallet & Statistics Update**:
     If `isWin == true`, adds `winAmount` back to `state.credits`, increments `totalWinnings`, and updates `biggestWin` if higher.
  7. **Persistence**:
     Saves the state immediately to `UserDefaults` using `StorePreference.shared.saveGameState(state)`.

### 3. Reel Animation & Physics

- **Class**: `SlotReelView`
- **Methods**: `spin(to:duration:completion:)`, `scheduleNextStep(token:)`, and `stopSpinAndSettle()`
- **Mechanics**:
  1. **Alternating Directions**: Reel 0 moves downward (`.topToBottom`), Reel 1 moves upward (`.bottomToTop`), Reel 2 moves downward (`.topToBottom`) using `CATransition` of type `.push`.
  2. **Deceleration Curve (`scheduleNextStep`)**:
     - _Phase 1 ($0.0 \le \text{progress} < 0.55$)_: Top speed at `0.04s` per symbol push.
     - _Phase 2 ($0.55 \le \text{progress} < 1.00$)_: Cubic ease-out slowdown:
       $$\Delta t = 0.04 + (\text{ease}^3 \times 0.18)$$
       Stretching frame intervals smoothly up to ~0.22s.
     - The target winning/losing symbol is pushed into the center frame at `progress > 0.88`.
  3. **Spring Bounce Overshoot (`stopSpinAndSettle`)**:
     Displaces the symbol container by `+8pt` (down) or `-8pt` (up) and springs back to `0` via `UIView.animate(usingSpringWithDamping: 0.68, initialSpringVelocity: 0.7)` while triggering mechanical stop haptics.

### 4. Reel Stop Completion & Win Resolution

- **Class**: `GameViewController`
- **Methods**: `handleAllReelsStopped(result:previousCredits:)`, `handleWin(result:fromCredits:)`, `handleLoss()`, and `animateCreditRollUp(from:to:)`
- **Flow**:
  1. When the third reel finishes its spring settle, `handleAllReelsStopped` stops the audio loop and re-enables bet adjustments.
  2. **If Win (`handleWin`)**:
     - Fires celebration haptic (`SoundManager.shared.playWinFeedback()`).
     - Highlights winning reel borders with a golden pulse (`reel.highlightWin()`).
     - Plays the Lottie confetti celebration (`animation_win.json`) centered over the reels (`playWinLottieAnimation()`).
     - Displays `WIN! +X CREDITS` (or `JACKPOT!` for 3x Star or Diamond) with spring scale animation.
     - Smoothly rolls up the credits label in 15 increments from deducted balance to winning total (`animateCreditRollUp`).
  3. **If Loss (`handleLoss`)**:
     - Displays a gentle "TRY AGAIN" spring message.
  4. Checks `gameEngine.canSpin()` to restore SPIN button state.

---

## Assumptions Made

1. **Target Device**: iPad landscape only, as specified in the take-home requirements. The UI scales proportionally to look great on both smaller iPads (mini) and larger 13" iPad Pro models.
2. **Payline**: Traditional center-row 3-of-a-kind payline.
3. **Audio**: Ambient category so users listening to music or podcasts don't get interrupted.

---

## How to Run & Test

### Running the App

1. Open `slotgametakehome.xcodeproj` in Xcode 15+.
2. Choose any iPad simulator (e.g. _iPad (A16)_, _iPad Pro 11-inch_).
3. Press **⌘R** to run.

### Running Unit Tests

Press **⌘U** in Xcode, or run from terminal:

```bash
xcodebuild test -project slotgametakehome.xcodeproj -scheme slotgametakehome -destination 'platform=iOS Simulator,name=iPad (A16)' -only-testing:slotgametakehomeTests
```

The unit test suite includes **25 unit tests** covering:
- `GameConfig` timings, sound asset verification, and Lottie JSON presence
- `StorePreference` defaults, custom state persistence, and resets
- `GameEngine` initial state, bet deduction, and lifetime statistics tracking
- Bet boundary and options validation (`GameConfig.betOptions`)
- All winning combinations and payout multipliers (🍒 Cherry 2x, 🍋 Lemon 3x, 7️⃣ Seven 5x, 🔔 Bell 10x, ⭐ Star 15x, 💎 Diamond 25x)
- Non-matching loss combinations and insufficient credits guard
- `SlotSymbol` probability weights and random weighted distribution
- `ThemeColor` dynamic alpha generation

### Running XCUI Automation Tests

Run from Xcode's Test Navigator or from terminal:

```bash
xcodebuild test -project slotgametakehome.xcodeproj -scheme slotgametakehome -destination 'platform=iOS Simulator,name=iPad (A16)' -only-testing:slotgametakehomeUITests/slotgametakehomeUITests -parallel-testing-enabled NO
```

The UI test suite includes **5 automated interaction tests**:
1. `testInitialGameScreenElements`: Verifies title, credits counter, segmented bet selector, reels container, and enabled SPIN button on launch.
2. `testBetSelectorChanges`: Verifies switching bets between 1, 5, and 10 updates the selected segment.
3. `testSpinCycleUpdatesStateAndReEnablesButton`: Taps SPIN, waits for reels to settle, verifies button re-enables and session statistics increment.
4. `testEnvironmentBadgeToggle`: Toggles DEV/PROD modes, asserting the QA test button is visible in DEV and hidden in PROD.
5. `testForcedOutcomeCherryWinFlow`: Uses the DEV test picker to select 3x Cherry, triggers a spin, and verifies the winning banner appears and credits increase.

---

