
//
//  slotgametakehomeTests.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.

import XCTest
@testable import slotgametakehome

final class slotgametakehomeTests: XCTestCase {

    var engine: GameEngine!
    var testDefaults: UserDefaults!
    var testPreferences: StorePreference!

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: "slotgametakehome.tests")!
        testDefaults.removePersistentDomain(forName: "slotgametakehome.tests")
        testPreferences = StorePreference(userDefaults: testDefaults)
        engine = GameEngine(preferences: testPreferences)
    }

    override func tearDown() {
        engine = nil
        testDefaults.removePersistentDomain(forName: "slotgametakehome.tests")
        testDefaults = nil
        testPreferences = nil
        super.tearDown()
    }

    // MARK: - GameConfig Tests

    func testGameConfigSoundFileName() {
        XCTAssertEqual(GameConfig.soundFileName, "spinning-sound.wav")
    }

    func testGameConfigAnimationTimings() {
        XCTAssertGreaterThan(GameConfig.baseSpinDuration, 0)
        XCTAssertGreaterThan(GameConfig.reelStaggerDelay, 0)
        XCTAssertGreaterThan(GameConfig.spinStepInterval, 0)
        XCTAssertGreaterThan(GameConfig.winAnimationDuration, 0)
        XCTAssertGreaterThan(GameConfig.resultAnimationDuration, 0)
    }

    func testWinAnimationFileExists() {
        let bundle = Bundle(for: GameViewController.self)
        let animationURL = bundle.url(forResource: "animation_win", withExtension: "json")
        XCTAssertNotNil(animationURL, "animation_win.json should be present in the bundle")
    }

    // MARK: - StorePreference Tests

    func testStorePreferenceDefaults() {
        XCTAssertFalse(testPreferences.hasSavedData)
        XCTAssertEqual(testPreferences.credits, GameConfig.initialCredits)
        XCTAssertEqual(testPreferences.lastBet, GameConfig.defaultBet)
        XCTAssertEqual(testPreferences.totalSpins, 0)
        XCTAssertEqual(testPreferences.biggestWin, 0)
        XCTAssertEqual(testPreferences.totalWinnings, 0)
    }

    func testStorePreferenceSaveAndLoad() {
        testPreferences.credits = 250
        testPreferences.lastBet = 10
        testPreferences.totalSpins = 12
        testPreferences.biggestWin = 50
        testPreferences.totalWinnings = 140

        XCTAssertTrue(testPreferences.hasSavedData)

        let loadedState = testPreferences.loadGameState()
        XCTAssertEqual(loadedState.credits, 250)
        XCTAssertEqual(loadedState.currentBet, 10)
        XCTAssertEqual(loadedState.totalSpins, 12)
        XCTAssertEqual(loadedState.biggestWin, 50)
        XCTAssertEqual(loadedState.totalWinnings, 140)
    }

    func testStorePreferenceReset() {
        testPreferences.credits = 500
        testPreferences.reset()

        XCTAssertFalse(testPreferences.hasSavedData)
        XCTAssertEqual(testPreferences.credits, GameConfig.initialCredits)
    }

    func testGameEnginePersistsScoreAcrossInstances() {
        engine.setBet(5)
        _ = engine.spin(forcedSymbols: [.bell, .bell, .bell]) // 5 * 10 = +50 win

        let savedCredits = engine.currentState.credits
        let savedSpins = engine.currentState.totalSpins

        // Create a new engine instance using the same preferences
        let newEngine = GameEngine(preferences: testPreferences)
        XCTAssertEqual(newEngine.currentState.credits, savedCredits)
        XCTAssertEqual(newEngine.currentState.totalSpins, savedSpins)
        XCTAssertEqual(newEngine.currentState.currentBet, 5)
    }

    // MARK: - Initial State Tests

    func testInitialGameState() {
        let state = engine.currentState
        XCTAssertEqual(state.credits, GameConfig.initialCredits)
        XCTAssertEqual(state.currentBet, GameConfig.defaultBet)
        XCTAssertEqual(state.totalSpins, 0)
        XCTAssertEqual(state.biggestWin, 0)
        XCTAssertEqual(state.totalWinnings, 0)
        XCTAssertTrue(engine.canSpin())
    }

    // MARK: - Bet Selection Tests

    func testSetBet() {
        engine.setBet(5)
        XCTAssertEqual(engine.currentState.currentBet, 5)

        engine.setBet(10)
        XCTAssertEqual(engine.currentState.currentBet, 10)

        engine.setBet(1)
        XCTAssertEqual(engine.currentState.currentBet, 1)
    }

    // MARK: - Spin and Balance Management Tests

    func testSpinDeductsBet() {
        engine.setBet(5)
        let initialCredits = engine.currentState.credits
        let result = engine.spin(forcedSymbols: [.cherry, .lemon, .bell]) // Guarantees loss

        XCTAssertFalse(result.isWin)
        XCTAssertEqual(engine.currentState.credits, initialCredits - 5)
        XCTAssertEqual(engine.currentState.totalSpins, 1)
    }

    func testInsufficientCreditsCannotSpin() {
        // Force spend all credits
        engine.setBet(10)
        for _ in 0..<10 {
            _ = engine.spin(forcedSymbols: [.cherry, .lemon, .seven])
        }

        XCTAssertEqual(engine.currentState.credits, 0)
        XCTAssertFalse(engine.canSpin())

        let result = engine.spin()
        XCTAssertEqual(result.symbols.count, 0)
        XCTAssertEqual(result.winAmount, 0)
    }

    // MARK: - Payout and Win Detection Tests

    func testCherryWinningCombination() {
        engine.setBet(5)
        let result = engine.spin(forcedSymbols: [.cherry, .cherry, .cherry])
        XCTAssertTrue(result.isWin)
        XCTAssertEqual(result.payout, 2)
        XCTAssertEqual(result.winAmount, 10)
        XCTAssertEqual(result.winningSymbol, .cherry)
    }

    func testLemonWinningCombination() {
        engine.setBet(10)
        let result = engine.spin(forcedSymbols: [.lemon, .lemon, .lemon])
        XCTAssertTrue(result.isWin)
        XCTAssertEqual(result.payout, 3)
        XCTAssertEqual(result.winAmount, 30)
    }

    func testSevenWinningCombination() {
        engine.setBet(1)
        let result = engine.spin(forcedSymbols: [.seven, .seven, .seven])
        XCTAssertTrue(result.isWin)
        XCTAssertEqual(result.payout, 5)
        XCTAssertEqual(result.winAmount, 5)
    }

    func testBellWinningCombination() {
        engine.setBet(5)
        let result = engine.spin(forcedSymbols: [.bell, .bell, .bell])
        XCTAssertTrue(result.isWin)
        XCTAssertEqual(result.payout, 10)
        XCTAssertEqual(result.winAmount, 50)
    }

    func testStarWinningCombination() {
        engine.setBet(1)
        let result = engine.spin(forcedSymbols: [.star, .star, .star])
        XCTAssertTrue(result.isWin)
        XCTAssertEqual(result.payout, 15)
        XCTAssertEqual(result.winAmount, 15)
    }

    func testDiamondWinningCombination() {
        engine.setBet(10)
        let result = engine.spin(forcedSymbols: [.diamond, .diamond, .diamond])
        XCTAssertTrue(result.isWin)
        XCTAssertEqual(result.payout, 25)
        XCTAssertEqual(result.winAmount, 250)
    }

    func testNonMatchingCombinationIsLoss() {
        let result = engine.spin(forcedSymbols: [.cherry, .bell, .cherry])
        XCTAssertFalse(result.isWin)
        XCTAssertEqual(result.payout, 0)
        XCTAssertEqual(result.winAmount, 0)
        XCTAssertNil(result.winningSymbol)
    }

    // MARK: - Statistics Tracking Tests

    func testStatisticsTracking() {
        engine.setBet(10)
        _ = engine.spin(forcedSymbols: [.diamond, .diamond, .diamond]) // +250 win
        _ = engine.spin(forcedSymbols: [.cherry, .lemon, .seven])      // loss
        _ = engine.spin(forcedSymbols: [.lemon, .lemon, .lemon])       // +30 win

        let state = engine.currentState
        XCTAssertEqual(state.totalSpins, 3)
        XCTAssertEqual(state.biggestWin, 250)
        XCTAssertEqual(state.totalWinnings, 280)
    }

    // MARK: - Reset Game Tests

    func testResetGame() {
        engine.setBet(5)
        _ = engine.spin(forcedSymbols: [.diamond, .diamond, .diamond])
        engine.resetGame()

        let state = engine.currentState
        XCTAssertEqual(state.credits, GameConfig.initialCredits)
        XCTAssertEqual(state.currentBet, GameConfig.defaultBet)
        XCTAssertEqual(state.totalSpins, 0)
        XCTAssertEqual(state.biggestWin, 0)
        XCTAssertEqual(state.totalWinnings, 0)
    }

    // MARK: - Symbol & Weight Validation Tests

    func testSlotSymbolProperties() {
        XCTAssertEqual(SlotSymbol.allCases.count, 6)

        for symbol in SlotSymbol.allCases {
            XCTAssertGreaterThan(symbol.payout, 0, "\(symbol) must award a positive payout multiplier")
            XCTAssertGreaterThan(symbol.weight, 0, "\(symbol) must have a non-zero probability weight")
            XCTAssertFalse(symbol.imageName.isEmpty, "\(symbol) must define an image asset name")
        }

        // Verify jackpot is highest multiplier
        XCTAssertEqual(SlotSymbol.diamond.payout, 25)
        XCTAssertEqual(SlotSymbol.star.payout, 15)
    }

    func testRandomWeightedGeneratesValidSymbols() {
        var observedSymbols = Set<SlotSymbol>()
        for _ in 0..<100 {
            let symbol = SlotSymbol.randomWeighted()
            observedSymbols.insert(symbol)
        }
        XCTAssertFalse(observedSymbols.isEmpty)
    }

    // MARK: - Predefined Spin Option Tests

    func testAllPredefinedSpinOptions() {
        XCTAssertNil(PredefinedSpinOption.random.forcedSymbols)
        XCTAssertEqual(PredefinedSpinOption.cherry.forcedSymbols, [.cherry, .cherry, .cherry])
        XCTAssertEqual(PredefinedSpinOption.lemon.forcedSymbols, [.lemon, .lemon, .lemon])
        XCTAssertEqual(PredefinedSpinOption.seven.forcedSymbols, [.seven, .seven, .seven])
        XCTAssertEqual(PredefinedSpinOption.bell.forcedSymbols, [.bell, .bell, .bell])
        XCTAssertEqual(PredefinedSpinOption.star.forcedSymbols, [.star, .star, .star])
        XCTAssertEqual(PredefinedSpinOption.diamond.forcedSymbols, [.diamond, .diamond, .diamond])
        XCTAssertEqual(PredefinedSpinOption.loss.forcedSymbols, [.cherry, .lemon, .seven])
    }

    // MARK: - Theme Color Tests

    func testThemeColorDynamicAlpha() {
        let fullGold = ThemeColor.gold()
        let halfGold = ThemeColor.gold(alpha: 0.5)

        var fullAlpha: CGFloat = 0
        fullGold.getWhite(nil, alpha: &fullAlpha)

        var customAlpha: CGFloat = 0
        halfGold.getWhite(nil, alpha: &customAlpha)

        XCTAssertEqual(fullAlpha, 1.0, accuracy: 0.05)
        XCTAssertEqual(customAlpha, 0.5, accuracy: 0.05)
    }

    // MARK: - Bet Validation Tests

    func testInvalidBetIgnored() {
        engine.setBet(5)
        XCTAssertEqual(engine.currentState.currentBet, 5)

        // Invalid bets outside GameConfig.betOptions should be ignored
        engine.setBet(99)
        XCTAssertEqual(engine.currentState.currentBet, 5)

        engine.setBet(-1)
        XCTAssertEqual(engine.currentState.currentBet, 5)
    }
}

