//
//  GameViewController.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.

import UIKit
import Lottie

/// Main game view controller managing the slot machine interface, reel animations,
/// user interactions, game state coordination, and win celebration effects.
final class GameViewController: UIViewController {

    // MARK: - Core Game Engine & State
    /// Handles credit calculations, bet validation, and spin outcome generation.
    private let gameEngine = GameEngine()

    /// Array holding the 3 mechanical-style slot reel columns.
    private var reels: [SlotReelView] = []

    /// Flag indicating whether the reels are actively spinning to avoid concurrent spin calls.
    private var isSpinning: Bool = false

    // MARK: - UI Views & Display Components
    /// Fullscreen vintage marquee cabinet background.
    private let backgroundImageView = UIImageView()

    /// Title label displayed at the top marquee header.
    private let titleLabel = UILabel()

    /// Displays the player's current credit balance.
    private let creditsLabel = UILabel()

    /// Label identifying the bet denomination selector.
    private let betLabel = UILabel()

    /// Segmented control allowing selection of bet amounts (1, 5, 10 credits).
    private let betSegmentedControl = UISegmentedControl(items: GameConfig.betOptions.map { "\($0)" })

    /// Container view holding the 3 reel column subviews.
    private let reelsContainerView = UIView()

    /// Lottie animation view superimposed over the reels for win celebrations.
    private var winLottieAnimationView: LottieAnimationView?

    /// Label presenting win amounts, jackpot notices, or loss messages.
    private let resultLabel = UILabel()

    /// Label displaying historical gameplay statistics (Spins, Biggest Win, Total Won).
    private let statsLabel = UILabel()

    /// Primary arcade action push-button to trigger reel spinning.
    private let spinButton = UIButton(type: .custom)

    // MARK: - Development & Testing Controls
    /// Container hosting development controls (environment badge and test result picker).
    private let devContainerView = UIView()

    /// Button allowing toggling between Development mode (DEV) and Production mode (PROD).
    private let envBadgeButton = UIButton(type: .system)

    /// Dropdown button providing predefined spin outcome options for test verification.
    private let testResultButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI(animatedCredits: false)
    }

    /// Strictly enforces landscape orientation support.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    /// Prefers landscape right when presenting the view controller.
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    // MARK: - Layout Guides for Marquee Frame
    /// Play area strictly bounded within the inner dark teal board of the marquee image.
    private let innerPlayArea = UIView()

    /// Top guide representing the height of the top marquee lights and golden frame.
    private let topMarqueeGuide = UILayoutGuide()

    /// Bottom guide representing the height of the bottom marquee lights and frame.
    private let bottomMarqueeGuide = UILayoutGuide()

    /// Leading guide representing the margin occupied by the left light bulbs.
    private let leadingMarqueeGuide = UILayoutGuide()

    /// Trailing guide representing the margin occupied by the right light bulbs.
    private let trailingMarqueeGuide = UILayoutGuide()

    // MARK: - UI Setup Process
    /// Orchestrates the initialization and hierarchical assembly of all UI components.
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.35, green: 0.05, blue: 0.05, alpha: 1.0)

        setupBackground()
        setupMarqueeArea()
        setupTitle()
        setupHeader()
        setupReels()
        setupLottieAnimation()
        setupFooter()
        setupDevControls()
        setupConstraints()
    }

    /// Configures the background image to fill the screen edge-to-edge.
    private func setupBackground() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = UIImage(named: "reels-background-only")
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
    }

    /// Establishes the layout guides matching the inner bounds of the marquee light bulbs.
    private func setupMarqueeArea() {
        view.addLayoutGuide(topMarqueeGuide)
        view.addLayoutGuide(bottomMarqueeGuide)
        view.addLayoutGuide(leadingMarqueeGuide)
        view.addLayoutGuide(trailingMarqueeGuide)

        innerPlayArea.translatesAutoresizingMaskIntoConstraints = false
        innerPlayArea.backgroundColor = .clear
        view.addSubview(innerPlayArea)
    }

    /// Initializes and styles the game title label with arcade glowing drop shadows.
    private func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "SLOT MACHINE"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.8).cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowOpacity = 0.85
        titleLabel.layer.shadowRadius = 6
        innerPlayArea.addSubview(titleLabel)
    }

    /// Configures the credits balance indicator and the bet denomination selector.
    private func setupHeader() {
        // Credits Label displaying player balance
        creditsLabel.translatesAutoresizingMaskIntoConstraints = false
        creditsLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .heavy)
        creditsLabel.textColor = .white
        creditsLabel.layer.shadowColor = UIColor.black.cgColor
        creditsLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        creditsLabel.layer.shadowOpacity = 0.7
        creditsLabel.layer.shadowRadius = 3
        innerPlayArea.addSubview(creditsLabel)

        // Bet Label identifying the selector
        betLabel.translatesAutoresizingMaskIntoConstraints = false
        betLabel.text = "BET"
        betLabel.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        betLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.9)
        innerPlayArea.addSubview(betLabel)

        // Bet Segmented Control with custom gold/dark arcade theme
        betSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        betSegmentedControl.selectedSegmentIndex = 0
        betSegmentedControl.backgroundColor = UIColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 0.90)
        betSegmentedControl.selectedSegmentTintColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)

        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: .heavy)
        ]
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13, weight: .bold)
        ]
        betSegmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        betSegmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        betSegmentedControl.addTarget(self, action: #selector(betChanged(_:)), for: .valueChanged)
        innerPlayArea.addSubview(betSegmentedControl)
    }

    /// Initializes 3 mechanical reel columns and assigns alternating scrolling directions:
    /// - Column 1: Top-to-Bottom
    /// - Column 2: Bottom-to-Top
    /// - Column 3: Top-to-Bottom
    private func setupReels() {
        reelsContainerView.translatesAutoresizingMaskIntoConstraints = false
        innerPlayArea.addSubview(reelsContainerView)

        let directions: [SpinDirection] = [.topToBottom, .bottomToTop, .topToBottom]

        for i in 0..<3 {
            let reel = SlotReelView()
            reel.translatesAutoresizingMaskIntoConstraints = false
            reel.spinDirection = directions[i]
            reelsContainerView.addSubview(reel)
            reels.append(reel)
        }
    }

    /// Initializes the Lottie celebration animation view (`animation_win.json`).
    /// The view is non-interactive (`isUserInteractionEnabled = false`) and placed
    /// directly on top of the reels container view, initially hidden (`alpha = 0`).
    private func setupLottieAnimation() {
        let animationView: LottieAnimationView
        if let path = Bundle.main.path(forResource: "animation_win", ofType: "json"),
           let animation = LottieAnimation.filepath(path) {
            animationView = LottieAnimationView(animation: animation)
        } else {
            animationView = LottieAnimationView(name: "animation_win", bundle: .main)
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1.0
        animationView.isUserInteractionEnabled = false
        animationView.alpha = 0
        innerPlayArea.addSubview(animationView)
        self.winLottieAnimationView = animationView

        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: reelsContainerView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: reelsContainerView.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: reelsContainerView.widthAnchor, multiplier: 1.15),
            animationView.heightAnchor.constraint(equalTo: reelsContainerView.heightAnchor, multiplier: 1.25)
        ])
    }

    /// Configures the footer elements: result announcement label, statistics tracking label,
    /// and the primary interactive SPIN button with 3D tactile push feedback.
    private func setupFooter() {
        // Result Label announcing wins, jackpots, or losses
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        resultLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        resultLabel.textAlignment = .center
        resultLabel.alpha = 0
        innerPlayArea.addSubview(resultLabel)

        // Stats Label displaying lifetime session statistics
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        statsLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        statsLabel.textColor = UIColor(white: 0.82, alpha: 0.9)
        statsLabel.textAlignment = .center
        innerPlayArea.addSubview(statsLabel)

        // Spin Button styled as an arcade push-button with glowing shadow
        spinButton.translatesAutoresizingMaskIntoConstraints = false
        spinButton.setTitle("SPIN", for: .normal)
        spinButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        spinButton.setTitleColor(.black, for: .normal)
        spinButton.setTitleColor(UIColor(white: 0.3, alpha: 1.0), for: .disabled)
        spinButton.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        spinButton.layer.cornerRadius = 25
        spinButton.layer.shadowColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.6).cgColor
        spinButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        spinButton.layer.shadowOpacity = 0.8
        spinButton.layer.shadowRadius = 8

        spinButton.addTarget(self, action: #selector(spinTouchDown), for: .touchDown)
        spinButton.addTarget(self, action: #selector(spinTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        spinButton.addTarget(self, action: #selector(spinTapped), for: .touchUpInside)
        innerPlayArea.addSubview(spinButton)
    }

    // MARK: - Development Controls Setup

    /// Assembles the QA/Developer HUD for toggling environments and injecting predefined test results.
    private func setupDevControls() {
        devContainerView.translatesAutoresizingMaskIntoConstraints = false
        devContainerView.backgroundColor = UIColor(red: 0.06, green: 0.08, blue: 0.14, alpha: 0.92)
        devContainerView.layer.cornerRadius = 8
        devContainerView.layer.borderWidth = 1
        devContainerView.layer.borderColor = UIColor(red: 0.3, green: 0.45, blue: 0.65, alpha: 0.5).cgColor
        innerPlayArea.addSubview(devContainerView)

        // Environment Toggle Badge (DEV / PROD)
        envBadgeButton.translatesAutoresizingMaskIntoConstraints = false
        envBadgeButton.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .heavy)
        envBadgeButton.backgroundColor = UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 0.95)
        envBadgeButton.layer.cornerRadius = 5
        envBadgeButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7)
        envBadgeButton.addTarget(self, action: #selector(toggleEnvironment), for: .touchUpInside)
        devContainerView.addSubview(envBadgeButton)

        // Predefined Result Picker Button with Native UIMenu Dropdown
        testResultButton.translatesAutoresizingMaskIntoConstraints = false
        testResultButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        testResultButton.setTitleColor(.white, for: .normal)
        testResultButton.backgroundColor = UIColor(white: 0.22, alpha: 0.7)
        testResultButton.layer.cornerRadius = 5
        testResultButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        testResultButton.showsMenuAsPrimaryAction = true
        devContainerView.addSubview(testResultButton)

        rebuildDevMenu()
        updateDevVisibility()
    }

    /// Rebuilds the UIMenu actions reflecting the currently selected test outcome.
    private func rebuildDevMenu() {
        let currentOption = GameConfig.selectedTestOption
        testResultButton.setTitle("Test: \(currentOption.rawValue)", for: .normal)

        let menuActions = PredefinedSpinOption.allCases.map { option in
            UIAction(
                title: option.rawValue,
                state: option == currentOption ? .on : .off
            ) { [weak self] _ in
                GameConfig.selectedTestOption = option
                self?.rebuildDevMenu()
            }
        }

        testResultButton.menu = UIMenu(title: "Select Predefined Outcome", children: menuActions)
        let isDev = (GameConfig.environment == .development)
        envBadgeButton.setTitle(isDev ? "DEV" : "PROD", for: .normal)
        envBadgeButton.backgroundColor = isDev ? UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 0.95) : UIColor(white: 0.28, alpha: 0.8)
        envBadgeButton.setTitleColor(.white, for: .normal)
    }

    /// Toggles the application between Development and Production modes.
    @objc private func toggleEnvironment() {
        if GameConfig.environment == .development {
            GameConfig.environment = .production
        } else {
            GameConfig.environment = .development
        }
        updateDevVisibility()
        rebuildDevMenu()
    }

    /// Updates visibility of test controls depending on whether the app is in Development or Production.
    private func updateDevVisibility() {
        let isDev = (GameConfig.environment == .development)
        testResultButton.isHidden = !isDev
        devContainerView.backgroundColor = isDev ? UIColor(red: 0.06, green: 0.08, blue: 0.14, alpha: 0.92) : .clear
        devContainerView.layer.borderWidth = isDev ? 1 : 0
    }

    // MARK: - Constraints

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background Image fills full screen edge-to-edge
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Marquee border guides matching the golden light-bulb rim
            topMarqueeGuide.topAnchor.constraint(equalTo: view.topAnchor),
            topMarqueeGuide.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.165),

            bottomMarqueeGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomMarqueeGuide.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.175),

            leadingMarqueeGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leadingMarqueeGuide.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.14),

            trailingMarqueeGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trailingMarqueeGuide.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.14),

            // Inner Play Area strictly contained within the dark teal marquee board
            innerPlayArea.topAnchor.constraint(equalTo: topMarqueeGuide.bottomAnchor),
            innerPlayArea.bottomAnchor.constraint(equalTo: bottomMarqueeGuide.topAnchor),
            innerPlayArea.leadingAnchor.constraint(equalTo: leadingMarqueeGuide.trailingAnchor),
            innerPlayArea.trailingAnchor.constraint(equalTo: trailingMarqueeGuide.leadingAnchor),

            // Title centered at the top of the play area
            titleLabel.topAnchor.constraint(equalTo: innerPlayArea.topAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: innerPlayArea.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 32),

            // Dev Controls in top-left of the inner play area, aligned with title
            devContainerView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            devContainerView.leadingAnchor.constraint(equalTo: innerPlayArea.leadingAnchor, constant: 10),
            devContainerView.heightAnchor.constraint(equalToConstant: 28),

            envBadgeButton.leadingAnchor.constraint(equalTo: devContainerView.leadingAnchor, constant: 4),
            envBadgeButton.centerYAnchor.constraint(equalTo: devContainerView.centerYAnchor),
            envBadgeButton.heightAnchor.constraint(equalToConstant: 22),

            testResultButton.leadingAnchor.constraint(equalTo: envBadgeButton.trailingAnchor, constant: 6),
            testResultButton.trailingAnchor.constraint(equalTo: devContainerView.trailingAnchor, constant: -4),
            testResultButton.centerYAnchor.constraint(equalTo: devContainerView.centerYAnchor),
            testResultButton.heightAnchor.constraint(equalToConstant: 22),

            // Header Elements (Credits on left, Bet on right)
            creditsLabel.leadingAnchor.constraint(equalTo: reelsContainerView.leadingAnchor),
            creditsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),

            betSegmentedControl.trailingAnchor.constraint(equalTo: reelsContainerView.trailingAnchor),
            betSegmentedControl.centerYAnchor.constraint(equalTo: creditsLabel.centerYAnchor),
            betSegmentedControl.widthAnchor.constraint(equalToConstant: 145),
            betSegmentedControl.heightAnchor.constraint(equalToConstant: 30),

            betLabel.trailingAnchor.constraint(equalTo: betSegmentedControl.leadingAnchor, constant: -8),
            betLabel.centerYAnchor.constraint(equalTo: creditsLabel.centerYAnchor),

            // Reels Container (centered in view)
            reelsContainerView.topAnchor.constraint(equalTo: creditsLabel.bottomAnchor, constant: 20),
            reelsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reelsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.48),
            reelsContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.40),

            // Reel Subviews inside Container
            reels[0].leadingAnchor.constraint(equalTo: reelsContainerView.leadingAnchor),
            reels[0].topAnchor.constraint(equalTo: reelsContainerView.topAnchor),
            reels[0].bottomAnchor.constraint(equalTo: reelsContainerView.bottomAnchor),

            reels[1].leadingAnchor.constraint(equalTo: reels[0].trailingAnchor, constant: 14),
            reels[1].topAnchor.constraint(equalTo: reelsContainerView.topAnchor),
            reels[1].bottomAnchor.constraint(equalTo: reelsContainerView.bottomAnchor),
            reels[1].widthAnchor.constraint(equalTo: reels[0].widthAnchor),

            reels[2].leadingAnchor.constraint(equalTo: reels[1].trailingAnchor, constant: 14),
            reels[2].trailingAnchor.constraint(equalTo: reelsContainerView.trailingAnchor),
            reels[2].topAnchor.constraint(equalTo: reelsContainerView.topAnchor),
            reels[2].bottomAnchor.constraint(equalTo: reelsContainerView.bottomAnchor),
            reels[2].widthAnchor.constraint(equalTo: reels[0].widthAnchor),

            // Result Label below Reels
            resultLabel.topAnchor.constraint(equalTo: reelsContainerView.bottomAnchor, constant: 8),
            resultLabel.centerXAnchor.constraint(equalTo: innerPlayArea.centerXAnchor),
            resultLabel.heightAnchor.constraint(equalToConstant: 22),

            // Stats Label below Result
            statsLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 4),
            statsLabel.centerXAnchor.constraint(equalTo: innerPlayArea.centerXAnchor),
            statsLabel.heightAnchor.constraint(equalToConstant: 16),

            // Spin Button below Stats, guaranteed inside innerPlayArea
            spinButton.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 10),
            spinButton.centerXAnchor.constraint(equalTo: innerPlayArea.centerXAnchor),
            spinButton.widthAnchor.constraint(equalToConstant: 190),
            spinButton.heightAnchor.constraint(equalToConstant: 50),
            spinButton.bottomAnchor.constraint(lessThanOrEqualTo: innerPlayArea.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - UI Synchronization & Game State Updates

    /// Synchronizes the visual labels, segmented controls, and button states with the underlying `GameEngine`.
    /// - Parameter animatedCredits: If true, performs a rolling counter animation on the balance label.
    private func updateUI(animatedCredits: Bool = false) {
        let state = gameEngine.currentState
        creditsLabel.text = "CREDITS: \(state.credits)"

        // Synchronize selected bet index
        if let index = GameConfig.betOptions.firstIndex(of: state.currentBet) {
            betSegmentedControl.selectedSegmentIndex = index
        }

        // Enable or disable spin button according to available balance and active spin state
        let canSpin = gameEngine.canSpin() && !isSpinning
        spinButton.isEnabled = canSpin
        spinButton.alpha = canSpin ? 1.0 : 0.45

        updateStats()
    }

    /// Refreshes the session statistics label (Total Spins, Highest Single Win, Total Credits Won).
    private func updateStats() {
        let state = gameEngine.currentState
        statsLabel.text = "Spins: \(state.totalSpins)  |  Biggest Win: \(state.biggestWin)  |  Total Won: \(state.totalWinnings)"
    }

    // MARK: - User Interaction Actions

    /// Triggered when the player changes the bet amount via the segmented control.
    @objc private func betChanged(_ sender: UISegmentedControl) {
        guard !isSpinning else { return }
        let selectedBet = GameConfig.betOptions[sender.selectedSegmentIndex]
        gameEngine.setBet(selectedBet)
        updateUI()
    }

    /// Provides tactile feedback by shrinking the spin button slightly on touch down.
    @objc private func spinTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.spinButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    /// Restores the spin button scale when the touch is released or canceled.
    @objc private func spinTouchUp() {
        UIView.animate(withDuration: 0.15) {
            self.spinButton.transform = .identity
        }
    }

    // MARK: - Spin Execution Workflow

    /// Primary spin action initiating the complete slot machine spin workflow:
    /// 1. Validation: Ensures reels are not already in motion and balance >= bet amount.
    /// 2. Control Lockdown: Disables the spin button and bet picker to prevent re-entrant calls.
    /// 3. Visual & Audio Reset: Fades out prior results, stops any active win animations, triggers spin sound and haptics.
    /// 4. Outcome Determination: Checks for testing overrides in Development mode or generates random RNG symbols.
    /// 5. Deducts bet immediately on UI and initiates staggered mechanical spinning across each column.
    @objc private func spinTapped() {
        guard !isSpinning else { return }

        // 1. Validate sufficient player balance
        guard gameEngine.canSpin() else {
            showInsufficientCreditsNotice()
            return
        }

        // 2. Lock controls for the duration of the spin
        isSpinning = true
        spinButton.isEnabled = false
        spinButton.alpha = 0.45
        betSegmentedControl.isEnabled = false

        // 3. Dismiss previous outcome labels and win celebration animations
        UIView.animate(withDuration: 0.2) {
            self.resultLabel.alpha = 0
            self.winLottieAnimationView?.alpha = 0
        } completion: { _ in
            self.winLottieAnimationView?.stop()
        }
        reels.forEach { $0.clearHighlight() }

        // 4. Start audio and haptic feedback
        SoundManager.shared.playSpinStartFeedback()
        SoundManager.shared.playSpinSound()

        // 5. Check if QA predefined test outcome should be injected (Development mode only)
        let forcedOutcome: [SlotSymbol]?
        if GameConfig.environment == .development {
            forcedOutcome = GameConfig.selectedTestOption.forcedSymbols
        } else {
            forcedOutcome = nil
        }

        // 6. Execute game engine calculation (deducts bet, evaluates win)
        let result = gameEngine.spin(forcedSymbols: forcedOutcome)

        // 7. Update balance immediately to reflect deduction before win addition
        let creditsAfterBet = gameEngine.currentState.credits - (result.isWin ? result.winAmount : 0)
        creditsLabel.text = "CREDITS: \(creditsAfterBet)"

        // 8. Launch staggered reel spinning (Reel 1 stops first, Reel 2 next, Reel 3 last)
        var completedReels = 0
        let totalReels = reels.count

        for (index, reel) in reels.enumerated() {
            let delay = Double(index) * GameConfig.reelStaggerDelay
            let duration = GameConfig.baseSpinDuration + delay
            let targetSymbol = result.symbols[index]

            reel.spin(to: targetSymbol, duration: duration) { [weak self] in
                completedReels += 1
                if completedReels == totalReels {
                    self?.handleAllReelsStopped(result: result, previousCredits: creditsAfterBet)
                }
            }
        }
    }

    // MARK: - Reel Completion & Win/Loss Resolution

    /// Synchronizes the completion of all 3 reels and transitions the game state.
    /// - Parameters:
    ///   - result: The outcome computed by the `GameEngine`.
    ///   - previousCredits: Balance right after bet deduction, used for rolling credit animation.
    private func handleAllReelsStopped(result: SpinResult, previousCredits: Int) {
        isSpinning = false
        SoundManager.shared.stopSpinSound()
        betSegmentedControl.isEnabled = true

        updateStats()

        if result.isWin {
            handleWin(result: result, fromCredits: previousCredits)
        } else {
            handleLoss()
        }

        let canSpin = gameEngine.canSpin()
        spinButton.isEnabled = canSpin
        spinButton.alpha = canSpin ? 1.0 : 0.45
    }

    /// Handles winning outcomes:
    /// - Plays winning haptic feedback.
    /// - Highlights winning payline symbols with a pulsing golden border glow.
    /// - Superimposes and plays the Lottie celebration animation on top of the reels.
    /// - Displays the winning multiplier / jackpot text with a spring pop animation.
    /// - Animate credit roll-up to visually add the winnings to the player's balance.
    private func handleWin(result: SpinResult, fromCredits: Int) {
        SoundManager.shared.playWinFeedback()
        reels.forEach { $0.highlightWin() }
        playWinLottieAnimation()

        let isJackpot = (result.winningSymbol == .diamond || result.winningSymbol == .star)
        let prefix = isJackpot ? "JACKPOT! " : "WIN! "
        resultLabel.text = "\(prefix)+\(result.winAmount) CREDITS"
        resultLabel.textColor = UIColor(red: 0.2, green: 0.95, blue: 0.3, alpha: 1.0)

        resultLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(
            withDuration: GameConfig.resultAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 0.8,
            options: [],
            animations: {
                self.resultLabel.alpha = 1
                self.resultLabel.transform = .identity
            }
        )

        animateCreditRollUp(from: fromCredits, to: gameEngine.currentState.credits)
    }

    /// Brings the Lottie celebration animation to the front, resets its progress to zero,
    /// plays through once, and smoothly fades it out upon completion.
    private func playWinLottieAnimation() {
        guard let lottie = winLottieAnimationView else { return }
        innerPlayArea.bringSubviewToFront(lottie)
        lottie.stop()
        lottie.currentProgress = 0
        lottie.alpha = 1.0

        lottie.play { [weak self] completed in
            guard completed else { return }
            UIView.animate(withDuration: 0.4, delay: 0.3, options: [.curveEaseOut]) {
                self?.winLottieAnimationView?.alpha = 0
            }
        }
    }

    /// Handles non-winning spins by showing a brief, subtle "TRY AGAIN" notice.
    private func handleLoss() {
        resultLabel.text = "TRY AGAIN"
        resultLabel.textColor = UIColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1.0)

        resultLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(
            withDuration: GameConfig.resultAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                self.resultLabel.alpha = 1
                self.resultLabel.transform = .identity
            }
        )
    }

    /// Progressively animates the credit balance upward in numbered increments,
    /// creating an authentic arcade roll-up counter effect.
    private func animateCreditRollUp(from startValue: Int, to endValue: Int) {
        let steps = 15
        let stepDuration = 0.03
        let increment = Double(endValue - startValue) / Double(steps)

        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * stepDuration) { [weak self] in
                let current = Int(Double(startValue) + increment * Double(step))
                self?.creditsLabel.text = "CREDITS: \(min(current, endValue))"
            }
        }
    }

    /// Alerts the user when attempting to spin with a balance lower than the selected bet,
    /// triggering a horizontal shake keyframe animation on the credits counter.
    private func showInsufficientCreditsNotice() {
        resultLabel.text = "INSUFFICIENT CREDITS"
        resultLabel.textColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        resultLabel.alpha = 1

        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: .linear)
        shake.duration = 0.4
        shake.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
        creditsLabel.layer.add(shake, forKey: "shake")
    }
}
