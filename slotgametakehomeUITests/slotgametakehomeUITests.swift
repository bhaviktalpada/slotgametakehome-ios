//
//  slotgametakehomeUITests.swift
//  slotgametakehomeUITests
//
//  Created by Developer on 22/10/26.
//

import XCTest

final class slotgametakehomeUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Initial UI State

    @MainActor
    func testInitialGameScreenElements() throws {
        let titleLabel = app.staticTexts["titleLabel"]
        XCTAssertTrue(titleLabel.waitForExistence(timeout: 3.0), "Game title should be visible on launch")
        XCTAssertEqual(titleLabel.label, "SLOT MACHINE")

        let creditsLabel = app.staticTexts["creditsLabel"]
        XCTAssertTrue(creditsLabel.exists, "Credits counter label must exist")
        XCTAssertTrue(creditsLabel.label.contains("CREDITS"), "Credits label must display CREDITS header")

        let betControl = app.segmentedControls["betSegmentedControl"]
        XCTAssertTrue(betControl.exists, "Bet selector must be present")
        XCTAssertTrue(betControl.buttons["1"].exists)
        XCTAssertTrue(betControl.buttons["5"].exists)
        XCTAssertTrue(betControl.buttons["10"].exists)

        let spinButton = app.buttons["spinButton"]
        XCTAssertTrue(spinButton.exists, "SPIN button must exist")
        XCTAssertTrue(spinButton.isEnabled, "SPIN button should be enabled initially")

        let reelsContainer = app.otherElements["reelsContainerView"]
        XCTAssertTrue(reelsContainer.exists, "Reels container must be present")
    }

    // MARK: - Bet Selector Interaction

    @MainActor
    func testBetSelectorChanges() throws {
        let betControl = app.segmentedControls["betSegmentedControl"]
        XCTAssertTrue(betControl.waitForExistence(timeout: 2.0))

        // Select 5
        let segment5 = betControl.buttons["5"]
        segment5.tap()
        XCTAssertTrue(segment5.isSelected, "Bet 5 segment should be selected after tap")

        // Select 10
        let segment10 = betControl.buttons["10"]
        segment10.tap()
        XCTAssertTrue(segment10.isSelected, "Bet 10 segment should be selected after tap")

        // Select 1
        let segment1 = betControl.buttons["1"]
        segment1.tap()
        XCTAssertTrue(segment1.isSelected, "Bet 1 segment should be selected after tap")
    }

    // MARK: - Spin Cycle & Button State

    @MainActor
    func testSpinCycleUpdatesStateAndReEnablesButton() throws {
        let spinButton = app.buttons["spinButton"]
        XCTAssertTrue(spinButton.waitForExistence(timeout: 2.0))
        XCTAssertTrue(spinButton.isEnabled, "SPIN button should be enabled before spin")

        spinButton.tap()

        // Button should re-enable once all reels settle (~3.5s total spin duration)
        let enabledPredicate = NSPredicate(format: "isEnabled == true")
        let enabledExpectation = expectation(for: enabledPredicate, evaluatedWith: spinButton, handler: nil)
        wait(for: [enabledExpectation], timeout: 8.0)

        XCTAssertTrue(spinButton.isEnabled, "SPIN button must be re-enabled after reels settle")

        // Verify session stats updated to reflect completed spin
        let statsLabel = app.staticTexts["statsLabel"]
        XCTAssertTrue(statsLabel.waitForExistence(timeout: 2.0))
        XCTAssertTrue(statsLabel.label.contains("Spins:"), "Stats label should display spin count")
    }

    // MARK: - DEV / PROD Environment Toggle

    @MainActor
    func testEnvironmentBadgeToggle() throws {
        let envBadge = app.buttons["envBadgeButton"]
        let testButton = app.buttons["testResultButton"]

        XCTAssertTrue(envBadge.waitForExistence(timeout: 2.0))
        XCTAssertTrue(testButton.exists, "Test button should be visible in DEV mode")

        // Toggle to PROD
        envBadge.tap()
        XCTAssertEqual(envBadge.label, "PROD")
        XCTAssertFalse(testButton.isHittable, "Test button should be hidden in PROD mode")

        // Toggle back to DEV
        envBadge.tap()
        XCTAssertEqual(envBadge.label, "DEV")
        XCTAssertTrue(testButton.isHittable, "Test button should be visible again in DEV mode")
    }

    // MARK: - QA Test Outcome Injection & Win Resolution

    @MainActor
    func testForcedOutcomeCherryWinFlow() throws {
        let testButton = app.buttons["testResultButton"]
        XCTAssertTrue(testButton.waitForExistence(timeout: 2.0))

        // Open menu and pick 3x Cherry
        testButton.tap()

        let cherryOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Cherry'")).firstMatch
        if cherryOption.waitForExistence(timeout: 2.0) {
            cherryOption.tap()
        }

        // Tap Spin
        let spinButton = app.buttons["spinButton"]
        spinButton.tap()

        // Wait for spin to complete
        let enabledPredicate = NSPredicate(format: "isEnabled == true")
        let enabledExpectation = expectation(for: enabledPredicate, evaluatedWith: spinButton, handler: nil)
        wait(for: [enabledExpectation], timeout: 6.0)

        // Result label should indicate a win
        let resultLabel = app.staticTexts["resultLabel"]
        XCTAssertTrue(resultLabel.waitForExistence(timeout: 2.0))
        XCTAssertTrue(resultLabel.label.contains("WIN"), "Result banner should announce WIN on 3x Cherry")
    }
}
