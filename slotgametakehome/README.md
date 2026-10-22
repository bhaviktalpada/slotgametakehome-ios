# iOS Slot Game Take-Home Challenge

## Overview

Create a simple iOS slot machine game from scratch in **2 hours**. Please make sure code should not look like AI generated code for you, we want to see YOUR coding style. This challenge is designed to assess your iOS development skills, game logic implementation, and UI/UX capabilities.

## Requirements

### Project Setup (5-10 minutes)

- Create a new iOS project in Xcode (iOS 15.0+ minimum deployment target)
- **Target iPad in landscape orientation** for optimal slot machine experience
- Use Swift and UIKit or SwiftUI (your choice)

### Core Features (Required - 90 minutes)

#### 1. Basic Slot Machine Interface

- **3 spinning reels** displayed horizontally
- **Play button** to start the game
- **Credits balance display** showing current credits (start with 100 credits)
- **Bet amount selector** (1, 5, 10 credits per spin)
- Clean, intuitive UI optimized for **iPad landscape orientation**
- An example of a slot game layout has been provided as a reference as well as symbol assets and a background. Using these are optional.

#### 2. Game Mechanics

- **Symbol Set**: Use the provided PNG symbols (or create your own)
  - Included: Cherry, Lemon, Seven, Bell, Star, Diamond
  - All symbols provided in @1x, @2x, and @3x resolutions
- **Spinning Animation**: Reels should visually "spin" before stopping
- **Win Detection**:
  - 3 matching symbols = win
  - Different symbols have different payout multipliers
- **Balance Management**:
  - Deduct bet amount on spin
  - Add winnings to balance
  - Prevent spinning when balance < bet amount

#### 3. Win Logic & Payouts

Implement a payout table (example):

- Cherry-Cherry-Cherry = 2x bet
- Lemon-Lemon-Lemon = 3x bet
- Seven-Seven-Seven = 5x bet
- Bell-Bell-Bell = 10x bet
- Star-Star-Star = 15x bet
- Diamond-Diamond-Diamond = 25x bet

### Bonus Features (Optional - 30 minutes)

Choose one or more if time permits:

- **Sound effects** for spinning and winning
- **Win animations** (flash, pulse, etc.)
- **Statistics tracking** (total spins, biggest win, etc.)
- **Auto-spin** functionality
- **Jackpot feature** (rare 3x same symbol combination)
- **Better visual design** with custom graphics

## Technical Requirements

### Code Quality

- Use appropriate design patterns (MVC, MVVM, etc.)
- Implement proper separation of concerns
- Write clean, readable code with meaningful variable names
- Add comments for complex logic
- Handle edge cases (insufficient balance, etc.)

### Architecture Suggestions

Consider organizing your code with:

```
Models/
├── SlotMachine.swift
├── GameEngine.swift
└── Symbol.swift

Views/
├── SlotReelView.swift
├── GameViewController.swift
└── (Custom UI components)

Controllers/
└── GameViewController.swift (if using MVC)
```

## Evaluation Criteria

### Technical Skills (60%)

- **Code Organization** (20%): Clean architecture, proper separation of concerns
- **Game Logic Implementation** (20%): Correct win detection, balance management
- **UI Implementation** (20%): Functional interface, smooth animations

### Problem Solving (30%)

- **Edge Case Handling**: What happens when balance is insufficient?
- **User Experience**: Is the game intuitive and enjoyable?
- **Code Efficiency**: Appropriate algorithms and data structures

### Bonus Points (10%)

- **Polish & Creativity**: Visual appeal, sound, additional features
- **Documentation**: Clear README, code comments
- **Git Usage**: Meaningful commit history

## Submission Requirements

### What to Submit

1. **Complete Xcode project** (zipped or GitHub repository link)
2. **README.md** with:
   - Brief description of your approach
   - Features implemented
   - Any assumptions made
   - Instructions to run the project
   - What you would improve with more time

### Time Expectations

- **Total Time**: 2 hours maximum
- **Core Features**: Should be completed within 90 minutes
- **Polish/Bonus**: Remaining 30 minutes

### Submission Checklist

- [ ] Project builds and runs without errors
- [ ] All core features are implemented and functional
- [ ] Code is clean and well-organized
- [ ] Git repository with commit history
- [ ] README.md explaining your implementation

## Starter Assets (Optional)

We've provided basic visual assets in the `/Assets` folder to help you get started:

- **Background template** with reel areas positioned
- **Reel frames** for professional appearance
- **Custom PNG symbols** (Cherry, Lemon, Seven, Bell, Star, Diamond)
- **Symbol specifications** with payout suggestions and implementation examples
- **Spin button** design template
- **Color palette** and styling guidelines

**Note**: These assets are completely optional. You can use them, modify them, or create your own designs. Focus on functionality over visual perfection.

## Getting Started Tips

1. **Start Simple**: Get basic UI working first, then add game logic
2. **Incremental Development**: Make it work, then make it better
3. **Test Frequently**: Run your app after each major feature
4. **Time Management**: Spend 90 minutes on core features, 30 on polish
5. **Focus on Functionality**: A working simple game is better than a broken complex one
6. **Optional Assets**: Check the `/Assets` folder for starter graphics and color schemes

## Questions?

If you have any clarifying questions about the requirements, please don't hesitate to ask. Good luck, and have fun building your slot machine!

---

**Expected Deliverable**: A functional iOS slot machine game that demonstrates your iOS development skills, problem-solving ability, and attention to user experience.
