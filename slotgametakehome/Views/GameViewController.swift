//
//  GameViewController.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.
//

import UIKit
import Lottie

class GameViewController: UIViewController {

    private let gameEngine = GameEngine()
    private var reels: [SlotReelView] = []
    private var isSpinning = false

    // UI elements
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let creditsLabel = UILabel()
    private let betLabel = UILabel()
    private let betSegmentedControl = UISegmentedControl(items: GameConfig.betOptions.map { "\($0)" })
    private let reelsContainerView = UIView()
    private var winLottieAnimationView: LottieAnimationView?
    private let resultLabel = UILabel()
    private let statsLabel = UILabel()
    private let spinButton = UIButton(type: .custom)

    // Dev mode controls
    private let devContainerView = UIView()
    private let envBadgeButton = UIButton(type: .system)
    private let testResultButton = UIButton(type: .system)

    // Inner play bounds to keep controls away from the background frame bulbs
    private let innerPlayArea = UIView()
    private let topMarqueeGuide = UILayoutGuide()
    private let bottomMarqueeGuide = UILayoutGuide()
    private let leadingMarqueeGuide = UILayoutGuide()
    private let trailingMarqueeGuide = UILayoutGuide()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI(animatedCredits: false)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .landscapeRight
    }

    private func setupUI() {
        view.backgroundColor = ThemeColor.arcadeBackground()

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

    private func setupBackground() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = UIImage(named: "reels-background-only")
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
    }

    private func setupMarqueeArea() {
        view.addLayoutGuide(topMarqueeGuide)
        view.addLayoutGuide(bottomMarqueeGuide)
        view.addLayoutGuide(leadingMarqueeGuide)
        view.addLayoutGuide(trailingMarqueeGuide)

        innerPlayArea.translatesAutoresizingMaskIntoConstraints = false
        innerPlayArea.backgroundColor = .clear
        view.addSubview(innerPlayArea)
    }

    private func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "SLOT MACHINE"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        titleLabel.textColor = ThemeColor.gold()
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = ThemeColor.orangeGlow(alpha: 0.8).cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowOpacity = 0.85
        titleLabel.layer.shadowRadius = 6
        titleLabel.accessibilityIdentifier = "titleLabel"
        innerPlayArea.addSubview(titleLabel)
    }

    private func setupHeader() {
        creditsLabel.translatesAutoresizingMaskIntoConstraints = false
        creditsLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .heavy)
        creditsLabel.textColor = .white
        creditsLabel.layer.shadowColor = UIColor.black.cgColor
        creditsLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        creditsLabel.layer.shadowOpacity = 0.7
        creditsLabel.layer.shadowRadius = 3
        creditsLabel.accessibilityIdentifier = "creditsLabel"
        innerPlayArea.addSubview(creditsLabel)

        betLabel.translatesAutoresizingMaskIntoConstraints = false
        betLabel.text = "BET"
        betLabel.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        betLabel.textColor = ThemeColor.gold(alpha: 0.9)
        innerPlayArea.addSubview(betLabel)

        betSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        betSegmentedControl.accessibilityIdentifier = "betSegmentedControl"
        betSegmentedControl.selectedSegmentIndex = 0
        betSegmentedControl.backgroundColor = ThemeColor.controlBackground(alpha: 0.90)
        betSegmentedControl.selectedSegmentTintColor = ThemeColor.gold()

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

    private func setupReels() {
        reelsContainerView.translatesAutoresizingMaskIntoConstraints = false
        reelsContainerView.accessibilityIdentifier = "reelsContainerView"
        innerPlayArea.addSubview(reelsContainerView)

        // Alternating directions: Reel 1 down, Reel 2 up, Reel 3 down
        let directions: [SpinDirection] = [.topToBottom, .bottomToTop, .topToBottom]

        for i in 0..<3 {
            let reel = SlotReelView()
            reel.translatesAutoresizingMaskIntoConstraints = false
            reel.spinDirection = directions[i]
            reel.accessibilityIdentifier = "reel_\(i)"
            reelsContainerView.addSubview(reel)
            reels.append(reel)
        }
    }

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

    private func setupFooter() {
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        resultLabel.textColor = ThemeColor.gold()
        resultLabel.textAlignment = .center
        resultLabel.alpha = 0
        resultLabel.accessibilityIdentifier = "resultLabel"
        innerPlayArea.addSubview(resultLabel)

        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        statsLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        statsLabel.textColor = ThemeColor.statsText(alpha: 0.9)
        statsLabel.textAlignment = .center
        statsLabel.accessibilityIdentifier = "statsLabel"
        innerPlayArea.addSubview(statsLabel)

        spinButton.translatesAutoresizingMaskIntoConstraints = false
        spinButton.setTitle("SPIN", for: .normal)
        spinButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        spinButton.setTitleColor(.black, for: .normal)
        spinButton.setTitleColor(ThemeColor.disabledText(), for: .disabled)
        spinButton.backgroundColor = ThemeColor.gold()
        spinButton.layer.cornerRadius = 25
        spinButton.layer.shadowColor = ThemeColor.orangeGlow(alpha: 0.6).cgColor
        spinButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        spinButton.layer.shadowOpacity = 0.8
        spinButton.layer.shadowRadius = 8
        spinButton.accessibilityIdentifier = "spinButton"

        spinButton.addTarget(self, action: #selector(spinTouchDown), for: .touchDown)
        spinButton.addTarget(self, action: #selector(spinTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        spinButton.addTarget(self, action: #selector(spinTapped), for: .touchUpInside)
        innerPlayArea.addSubview(spinButton)
    }

    private func setupDevControls() {
        devContainerView.translatesAutoresizingMaskIntoConstraints = false
        devContainerView.backgroundColor = ThemeColor.devBackground(alpha: 0.92)
        devContainerView.layer.cornerRadius = 8
        devContainerView.layer.borderWidth = 1
        devContainerView.layer.borderColor = ThemeColor.devBorder(alpha: 0.5).cgColor
        innerPlayArea.addSubview(devContainerView)

        envBadgeButton.translatesAutoresizingMaskIntoConstraints = false
        envBadgeButton.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .heavy)
        envBadgeButton.backgroundColor = ThemeColor.devBadgeGreen(alpha: 0.95)
        envBadgeButton.layer.cornerRadius = 5
        envBadgeButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7)
        envBadgeButton.accessibilityIdentifier = "envBadgeButton"
        envBadgeButton.addTarget(self, action: #selector(toggleEnvironment), for: .touchUpInside)
        devContainerView.addSubview(envBadgeButton)

        testResultButton.translatesAutoresizingMaskIntoConstraints = false
        testResultButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        testResultButton.setTitleColor(.white, for: .normal)
        testResultButton.backgroundColor = ThemeColor.testButtonBackground(alpha: 0.7)
        testResultButton.layer.cornerRadius = 5
        testResultButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        testResultButton.accessibilityIdentifier = "testResultButton"
        testResultButton.showsMenuAsPrimaryAction = true
        devContainerView.addSubview(testResultButton)

        rebuildDevMenu()
        updateDevVisibility()
    }

    
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
        envBadgeButton.backgroundColor = isDev ? ThemeColor.devBadgeGreen(alpha: 0.95) : ThemeColor.prodBadgeGray(alpha: 0.8)
        envBadgeButton.setTitleColor(.white, for: .normal)
    }

    @objc private func toggleEnvironment(){
        GameConfig.environment = (GameConfig.environment == .development) ? .production : .development
        updateDevVisibility()
        rebuildDevMenu()
    }

    private func updateDevVisibility() {
        let isDev = (GameConfig.environment == .development)
        testResultButton.isHidden = !isDev
        devContainerView.backgroundColor = isDev ? ThemeColor.devBackground(alpha: 0.92) : .clear
        devContainerView.layer.borderWidth = isDev ? 1 : 0
    }

    private func setupConstraints(){
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Insets to stay inside the marquee border
            topMarqueeGuide.topAnchor.constraint(equalTo: view.topAnchor),
            topMarqueeGuide.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.165),

            bottomMarqueeGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomMarqueeGuide.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.175),

            leadingMarqueeGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leadingMarqueeGuide.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.14),

            trailingMarqueeGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trailingMarqueeGuide.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.14),

            innerPlayArea.topAnchor.constraint(equalTo: topMarqueeGuide.bottomAnchor),
            innerPlayArea.bottomAnchor.constraint(equalTo: bottomMarqueeGuide.topAnchor),
            innerPlayArea.leadingAnchor.constraint(equalTo: leadingMarqueeGuide.trailingAnchor),
            innerPlayArea.trailingAnchor.constraint(equalTo: trailingMarqueeGuide.leadingAnchor),

            titleLabel.topAnchor.constraint(equalTo: innerPlayArea.topAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: innerPlayArea.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 32),

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

            creditsLabel.leadingAnchor.constraint(equalTo: reelsContainerView.leadingAnchor),
            creditsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),

            betSegmentedControl.trailingAnchor.constraint(equalTo: reelsContainerView.trailingAnchor),
            betSegmentedControl.centerYAnchor.constraint(equalTo: creditsLabel.centerYAnchor),
            betSegmentedControl.widthAnchor.constraint(equalToConstant: 145),
            betSegmentedControl.heightAnchor.constraint(equalToConstant: 30),

            betLabel.trailingAnchor.constraint(equalTo: betSegmentedControl.leadingAnchor, constant: -8),
            betLabel.centerYAnchor.constraint(equalTo: creditsLabel.centerYAnchor),

            // Centered reels container
            reelsContainerView.topAnchor.constraint(equalTo: creditsLabel.bottomAnchor, constant: 20),
            reelsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reelsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.48),
            reelsContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.40),

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

            resultLabel.topAnchor.constraint(equalTo: reelsContainerView.bottomAnchor, constant: 8),
            resultLabel.centerXAnchor.constraint(equalTo: innerPlayArea.centerXAnchor),
            resultLabel.heightAnchor.constraint(equalToConstant: 22),

            statsLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 4),
            statsLabel.centerXAnchor.constraint(equalTo: innerPlayArea.centerXAnchor),
            statsLabel.heightAnchor.constraint(equalToConstant: 16),

            spinButton.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 10),
            spinButton.centerXAnchor.constraint(equalTo: innerPlayArea.centerXAnchor),
            spinButton.widthAnchor.constraint(equalToConstant: 190),
            spinButton.heightAnchor.constraint(equalToConstant: 50),
            spinButton.bottomAnchor.constraint(lessThanOrEqualTo: innerPlayArea.bottomAnchor, constant: -8)
        ])
    }

    private func updateUI(animatedCredits: Bool = false) {
        let state = gameEngine.currentState
        creditsLabel.text = "CREDITS: \(state.credits)"

        if let index = GameConfig.betOptions.firstIndex(of: state.currentBet) {
            betSegmentedControl.selectedSegmentIndex = index
        }

        let canSpin = gameEngine.canSpin() && !isSpinning
        spinButton.isEnabled = canSpin
        spinButton.alpha = canSpin ? 1.0 : 0.45

        updateStats()
    }

    private func updateStats() {
        let state = gameEngine.currentState
        statsLabel.text = "Spins: \(state.totalSpins)  |  Biggest Win: \(state.biggestWin)  |  Total Won: \(state.totalWinnings)"
    }

    @objc private func betChanged(_ sender: UISegmentedControl) {
        guard !isSpinning else { return }
        let selectedBet = GameConfig.betOptions[sender.selectedSegmentIndex]
        gameEngine.setBet(selectedBet)
        updateUI()
    }

    @objc private func spinTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.spinButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func spinTouchUp() {
        UIView.animate(withDuration: 0.15) {
            self.spinButton.transform = .identity
        }
    }

    // Spin button tap handler
    @objc private func spinTapped() {
        guard !isSpinning else { return }

        guard gameEngine.canSpin() else {
            showInsufficientCreditsNotice()
            return
        }

        // Lock inputs during spin
        isSpinning = true
        spinButton.isEnabled = false
        spinButton.alpha = 0.45
        betSegmentedControl.isEnabled = false

        UIView.animate(withDuration: 0.2) {
            self.resultLabel.alpha = 0
            self.winLottieAnimationView?.alpha = 0
        } completion: { _ in
            self.winLottieAnimationView?.stop()
        }
        reels.forEach { $0.clearHighlight() }

        SoundManager.shared.playSpinStartFeedback()
        SoundManager.shared.playSpinSound()

        // Check for dev test override
        let forcedOutcome = (GameConfig.environment == .development) ? GameConfig.selectedTestOption.forcedSymbols : nil
        let result = gameEngine.spin(forcedSymbols: forcedOutcome)

        // Show immediate balance reduction
        let creditsAfterBet = gameEngine.currentState.credits - (result.isWin ? result.winAmount : 0)
        creditsLabel.text = "CREDITS: \(creditsAfterBet)"

        // Stagger reel stops for mechanical anticipation
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

    // Handle on Win for result callback
    private func handleWin(result: SpinResult, fromCredits: Int) {
        SoundManager.shared.playWinFeedback()
        reels.forEach { $0.highlightWin() }
        playWinLottieAnimation()

        let isJackpot = (result.winningSymbol == .diamond || result.winningSymbol == .star)
        let prefix = isJackpot ? "JACKPOT! " : "WIN! "
        resultLabel.text = "\(prefix)+\(result.winAmount) CREDITS"
        resultLabel.textColor = ThemeColor.winGreen()

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

    /// Play lottie animation for any of the winning movement.
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

    // When no luck it shows TRY AGAIN
    private func handleLoss() {
        resultLabel.text = "TRY AGAIN"
        resultLabel.textColor = ThemeColor.lossRed()

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

    // Roll Up Credit label
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

    // When there is no credit available show Insufficient Credits notice label
    private func showInsufficientCreditsNotice() {
        resultLabel.text = "INSUFFICIENT CREDITS"
        resultLabel.textColor = ThemeColor.lossRed()
        resultLabel.alpha = 1

        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: .linear)
        shake.duration = 0.4
        shake.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
        creditsLabel.layer.add(shake, forKey: "shake")
    }
}
