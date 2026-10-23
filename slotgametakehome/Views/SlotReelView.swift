//
//  SlotReelView.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.

import UIKit

/// Delegate protocol notifying listeners when an individual reel completes its spin animation and settles.
protocol SlotReelViewDelegate: AnyObject {
    /// Notifies the delegate that the reel has finished spinning and settled on the target center symbol.
    /// - Parameters:
    ///   - reel: The `SlotReelView` instance that stopped.
    ///   - finalSymbol: The final `SlotSymbol` settled on the center payline.
    func reelDidFinishSpinning(_ reel: SlotReelView, finalSymbol: SlotSymbol)
}

/// Defines the vertical scrolling motion direction for a slot reel column.
enum SpinDirection {
    /// Symbols push downward (entering from the top, exiting through the bottom).
    case topToBottom
    /// Symbols push upward (entering from the bottom, exiting through the top).
    case bottomToTop
}

/// Custom view representing an individual vertical slot reel column with 3 visible symbol positions:
/// Top, Center (Payline), and Bottom.
/// Supports directional scrolling (top-to-bottom and bottom-to-top), soft deceleration physics,
/// and mechanical spring overshoot settling.
final class SlotReelView: UIView {

    // MARK: - Delegate & Public Properties
    /// Delegate receiving spin completion callbacks.
    weak var delegate: SlotReelViewDelegate?

    /// The vertical scrolling direction for this specific reel column.
    var spinDirection: SpinDirection = .topToBottom

    // MARK: - Subviews & UI Elements
    /// Container hosting all image views and indicators, animated for mechanical spring bounce.
    private let containerView = UIView()

    /// Displays the symbol above the payline (top row).
    private let topImageView = UIImageView()

    /// Displays the symbol on the active payline (center row).
    private let centerImageView = UIImageView()

    /// Displays the symbol below the payline (bottom row).
    private let bottomImageView = UIImageView()

    /// Subtle golden horizontal highlight background framing the center payline row.
    private let paylineIndicator = UIView()

    // MARK: - Spin Animation State
    /// Flag indicating whether the reel is actively running a spin cycle.
    private(set) var isSpinning: Bool = false

    /// Timestamp marking when the current spin cycle started.
    private var spinStartTime: Date?

    /// Planned total duration for the current spin cycle in seconds.
    private var totalSpinDuration: TimeInterval?

    /// The final target symbol designated to settle on the center payline.
    private var targetSymbol: SlotSymbol = .cherry

    /// Completion closure invoked when the reel finishes spinning and spring settling completes.
    private var onSpinComplete: (() -> Void)?

    /// Generation token incremented on each spin or stop to invalidate obsolete async steps.
    private var activeStepToken: Int = 0

    /// The symbol currently visible in the center payline position.
    private(set) var currentCenterSymbol: SlotSymbol = .cherry

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - UI Configuration Process

    /// Configures the reel's visual styling, background color, borders, and subview hierarchy.
    private func setupUI() {
        clipsToBounds = true
        backgroundColor = UIColor(red: 0.08, green: 0.10, blue: 0.15, alpha: 0.95)
        layer.cornerRadius = 14
        layer.borderWidth = 2
        layer.borderColor = UIColor(red: 0.25, green: 0.30, blue: 0.42, alpha: 0.7).cgColor

        // Container view hosting symbol rows
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        // Payline indicator (subtle gold horizontal highlight behind middle row)
        paylineIndicator.translatesAutoresizingMaskIntoConstraints = false
        paylineIndicator.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.08)
        paylineIndicator.layer.cornerRadius = 6
        containerView.addSubview(paylineIndicator)

        // Symbol image views (Top, Center, Bottom)
        [topImageView, centerImageView, bottomImageView].forEach { imageView in
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            containerView.addSubview(imageView)
        }

        setupConstraints()
        setInitialSymbols()
    }

    /// Establishes the Auto Layout constraints dividing the reel into 3 equal 1/3 height rows.
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container pinned to all edges of the reel view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Top Row (0 to 1/3 height)
            topImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            topImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            topImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            topImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1.0 / 3.0, constant: -12),

            // Center Row (1/3 to 2/3 height - Center Payline)
            centerImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            centerImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            centerImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            centerImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1.0 / 3.0, constant: -8),

            // Payline Indicator around center row
            paylineIndicator.centerYAnchor.constraint(equalTo: centerImageView.centerYAnchor),
            paylineIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            paylineIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            paylineIndicator.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1.0 / 3.0, constant: -4),

            // Bottom Row (2/3 to 3/3 height)
            bottomImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
            bottomImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            bottomImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            bottomImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1.0 / 3.0, constant: -12)
        ])
    }

    /// Seeds the reel with randomized initial symbols upon launch.
    private func setInitialSymbols() {
        let symbols = SlotSymbol.allCases.shuffled()
        topImageView.image = symbols[0].image
        centerImageView.image = symbols[1].image
        bottomImageView.image = symbols[2].image
        currentCenterSymbol = symbols[1]
    }

    // MARK: - Spin Animation & Deceleration Physics Process

    /// Initiates a spin cycle with soft deceleration physics in the reel's configured `spinDirection`.
    /// - Parameters:
    ///   - targetSymbol: The pre-calculated outcome symbol that will land on the center payline.
    ///   - duration: Total duration of the spin cycle in seconds before settling.
    ///   - completion: Closure called once the reel has completely stopped and spring settled.
    func spin(to targetSymbol: SlotSymbol, duration: TimeInterval, completion: @escaping () -> Void) {
        guard !isSpinning else { return }

        isSpinning = true
        self.targetSymbol = targetSymbol
        self.onSpinComplete = completion
        self.spinStartTime = Date()
        self.totalSpinDuration = duration
        self.activeStepToken += 1
        clearHighlight()

        // Dim non-payline top and bottom symbols slightly to emphasize center payline during spin
        topImageView.alpha = 0.6
        bottomImageView.alpha = 0.6

        scheduleNextStep(token: activeStepToken)
    }

    /// Schedules each animation frame in the spin cycle, implementing the soft deceleration curve.
    /// - Process:
    ///   1. Validates active step token to prevent execution if reel was canceled or reset.
    ///   2. Computes normalized progress `[0.0, 1.0]` based on elapsed time vs total spin duration.
    ///   3. Ramps step interval using a two-phase physics curve:
    ///      - Phase 1 (0.0 to 0.55 progress): High speed spinning at `GameConfig.spinStepInterval` (~0.04s).
    ///      - Phase 2 (0.55 to 1.00 progress): Smooth cubic ease-out deceleration slowing interval up to ~0.22s.
    ///   4. Transitions symbols via directional push transitions matching `spinDirection`.
    ///   5. Near the end (`progress > 0.88`), introduces the target symbol into the center position.
    ///   6. Once `progress >= 1.0`, triggers mechanical stop and spring settle.
    private func scheduleNextStep(token: Int) {
        guard isSpinning, token == activeStepToken,
              let startTime = spinStartTime,
              let totalDuration = totalSpinDuration else { return }

        let elapsed = Date().timeIntervalSince(startTime)
        let progress = min(1.0, elapsed / totalDuration)

        if progress >= 1.0 {
            stopSpinAndSettle()
            return
        }

        // Soft Deceleration Curve:
        // - Phase 1 (0.00 to 0.55): High-speed rapid blur (step interval ~ 0.04s)
        // - Phase 2 (0.55 to 1.00): Progressive cubic deceleration (step interval slows down to ~ 0.22s)
        let stepInterval: TimeInterval
        if progress < 0.55 {
            stepInterval = GameConfig.spinStepInterval
        } else {
            let decelProgress = (progress - 0.55) / 0.45
            let cubicEase = decelProgress * decelProgress * decelProgress
            stepInterval = GameConfig.spinStepInterval + (cubicEase * 0.18)
        }

        let transitionDuration = min(stepInterval * 0.85, 0.14)

        // Select symbols for the upcoming frame
        let nextTop: SlotSymbol
        let nextCenter: SlotSymbol
        let nextBottom: SlotSymbol

        if progress > 0.88 {
            // Near stop: introduce target symbol in center payline with diverse neighbors
            let nonTargetSymbols = SlotSymbol.allCases.filter { $0 != targetSymbol }
            nextTop = nonTargetSymbols.randomElement() ?? .cherry
            nextCenter = targetSymbol
            nextBottom = nonTargetSymbols.randomElement() ?? .lemon
        } else {
            // High-speed phase: randomize symbols according to rarity weights
            nextTop = SlotSymbol.randomWeighted()
            nextCenter = SlotSymbol.randomWeighted()
            nextBottom = SlotSymbol.randomWeighted()
        }

        // Apply directional push transitions matching reel spin direction
        applyDirectionalTransition(to: topImageView, newImage: nextTop.image, duration: transitionDuration)
        applyDirectionalTransition(to: centerImageView, newImage: nextCenter.image, duration: transitionDuration)
        applyDirectionalTransition(to: bottomImageView, newImage: nextBottom.image, duration: transitionDuration)

        // Schedule the subsequent step
        DispatchQueue.main.asyncAfter(deadline: .now() + stepInterval) { [weak self] in
            self?.scheduleNextStep(token: token)
        }
    }

    /// Applies a directional push `CATransition` to an image view.
    /// - Parameters:
    ///   - imageView: Target image view to transition.
    ///   - newImage: The new symbol image to display.
    ///   - duration: Transition duration in seconds.
    private func applyDirectionalTransition(to imageView: UIImageView, newImage: UIImage?, duration: TimeInterval) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: .linear)
        transition.type = .push

        switch spinDirection {
        case .topToBottom:
            // Pushes downward (enters from top, exits through bottom)
            transition.subtype = .fromTop
        case .bottomToTop:
            // Pushes upward (enters from bottom, exits through top)
            transition.subtype = .fromBottom
        }

        imageView.layer.add(transition, forKey: "directionalSpin")
        imageView.image = newImage
    }

    /// Stops the reel at the final target symbol and performs a directional spring overshoot settle.
    /// - Process:
    ///   1. Sets final symbols on top, center, and bottom image views.
    ///   2. Restores normal opacity to non-payline symbols.
    ///   3. Plays mechanical thud haptic feedback.
    ///   4. Displaces the container view in the direction of the spin (overshoot).
    ///   5. Animates back to identity using an authentic mechanical spring damping curve.
    ///   6. Notifies delegate and invokes completion handler.
    private func stopSpinAndSettle() {
        guard isSpinning else { return }
        isSpinning = false

        // Select context-fitting non-matching neighbors for top and bottom
        let nonTargetSymbols = SlotSymbol.allCases.filter { $0 != targetSymbol }
        let finalTop = nonTargetSymbols.randomElement() ?? .cherry
        let finalBottom = nonTargetSymbols.randomElement() ?? .lemon

        currentCenterSymbol = targetSymbol
        topImageView.image = finalTop.image
        centerImageView.image = targetSymbol.image
        bottomImageView.image = finalBottom.image

        // Restore symbol opacities
        topImageView.alpha = 0.85
        bottomImageView.alpha = 0.85

        // Haptic mechanical stop thud
        SoundManager.shared.playReelStopFeedback()

        // Directional spring bounce overshoot:
        // If moving top-to-bottom, overshoot downward (+8pt), then spring back up.
        // If moving bottom-to-top, overshoot upward (-8pt), then spring back down.
        let bounceOffset: CGFloat = (spinDirection == .topToBottom) ? 8.0 : -8.0
        containerView.transform = CGAffineTransform(translationX: 0, y: bounceOffset)

        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            usingSpringWithDamping: 0.68,
            initialSpringVelocity: 0.7,
            options: [.curveEaseOut],
            animations: {
                self.containerView.transform = .identity
            },
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.reelDidFinishSpinning(self, finalSymbol: self.targetSymbol)
                self.onSpinComplete?()
            }
        )
    }

    /// Forcefully halts the reel spin immediately (used during resets or view teardown).
    func stopSpin() {
        activeStepToken += 1
        isSpinning = false
    }

    // MARK: - Win Highlight Effects Process

    /// Highlights the winning reel payline symbol with an expanding pulse animation and golden border glow.
    func highlightWin() {
        layer.borderColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0).cgColor
        layer.borderWidth = 3
        paylineIndicator.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.3)

        UIView.animate(
            withDuration: GameConfig.winAnimationDuration / 2,
            delay: 0,
            options: [.autoreverse, .repeat],
            animations: {
                self.centerImageView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }
        )
    }

    /// Resets active win highlight borders, glow colors, and scale transforms back to default state.
    func clearHighlight() {
        centerImageView.layer.removeAllAnimations()
        centerImageView.transform = .identity
        layer.borderColor = UIColor(red: 0.25, green: 0.30, blue: 0.42, alpha: 0.7).cgColor
        layer.borderWidth = 2
        paylineIndicator.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.08)
    }
}
