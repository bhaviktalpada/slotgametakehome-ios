//
//  SlotReelView.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.
//

import UIKit

protocol SlotReelViewDelegate: AnyObject {
    func reelDidFinishSpinning(_ reel: SlotReelView, finalSymbol: SlotSymbol)
}

enum SpinDirection {
    case topToBottom
    case bottomToTop
}

// Single reel column displaying 3 visible symbol positions (top, payline center, bottom)
final class SlotReelView: UIView {

    weak var delegate: SlotReelViewDelegate?
    var spinDirection: SpinDirection = .topToBottom

    private let containerView = UIView()
    private let topImageView = UIImageView()
    private let centerImageView = UIImageView()
    private let bottomImageView = UIImageView()
    private let paylineIndicator = UIView()

    private(set) var isSpinning = false
    private var spinStartTime: Date?
    private var totalSpinDuration: TimeInterval?
    private var targetSymbol: SlotSymbol = .cherry
    private var onSpinComplete: (() -> Void)?
    private var activeStepToken = 0

    private(set) var currentCenterSymbol: SlotSymbol = .cherry

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        clipsToBounds = true
        backgroundColor = ThemeColor.reelBackground(alpha: 0.95)
        layer.cornerRadius = 14
        layer.borderWidth = 2
        layer.borderColor = ThemeColor.reelBorder(alpha: 0.7).cgColor

        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        // Subtle gold highlight behind the center payline row
        paylineIndicator.translatesAutoresizingMaskIntoConstraints = false
        paylineIndicator.backgroundColor = ThemeColor.gold(alpha: 0.08)
        paylineIndicator.layer.cornerRadius = 6
        containerView.addSubview(paylineIndicator)

        [topImageView, centerImageView, bottomImageView].forEach { imageView in
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            containerView.addSubview(imageView)
        }

        setupConstraints()
        setInitialSymbols()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Top row
            topImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            topImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            topImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            topImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1.0 / 3.0, constant: -12),

            // Center row (active payline)
            centerImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            centerImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            centerImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            centerImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1.0 / 3.0, constant: -8),

            paylineIndicator.centerYAnchor.constraint(equalTo: centerImageView.centerYAnchor),
            paylineIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            paylineIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            paylineIndicator.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1.0 / 3.0, constant: -4),

            // Bottom row
            bottomImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
            bottomImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            bottomImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            bottomImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1.0 / 3.0, constant: -12)
        ])
    }

    private func setInitialSymbols() {
        let symbols = SlotSymbol.allCases.shuffled()
        topImageView.image = symbols[0].image
        centerImageView.image = symbols[1].image
        bottomImageView.image = symbols[2].image
        currentCenterSymbol = symbols[1]
    }

    func spin(to targetSymbol: SlotSymbol, duration: TimeInterval, completion: @escaping () -> Void) {
        guard !isSpinning else { return }

        isSpinning = true
        self.targetSymbol = targetSymbol
        self.onSpinComplete = completion
        self.spinStartTime = Date()
        self.totalSpinDuration = duration
        self.activeStepToken += 1
        clearHighlight()

        topImageView.alpha = 0.6
        bottomImageView.alpha = 0.6

        scheduleNextStep(token: activeStepToken)
    }

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

        // Fast blur first, then cubic ease-out slowdown in the second half
        let stepInterval: TimeInterval
        if progress < 0.55 {
            stepInterval = GameConfig.spinStepInterval
        } else {
            let t = (progress - 0.55) / 0.45
            let ease = t * t * t
            stepInterval = GameConfig.spinStepInterval + (ease * 0.18)
        }

        let transitionDuration = min(stepInterval * 0.85, 0.14)

        let nextTop: SlotSymbol
        let nextCenter: SlotSymbol
        let nextBottom: SlotSymbol

        if progress > 0.88 {
            // Near the stop: place the final target symbol into the center payline
            let pool = SlotSymbol.allCases.filter { $0 != targetSymbol }
            nextTop = pool.randomElement() ?? .cherry
            nextCenter = targetSymbol
            nextBottom = pool.randomElement() ?? .lemon
        } else {
            nextTop = SlotSymbol.randomWeighted()
            nextCenter = SlotSymbol.randomWeighted()
            nextBottom = SlotSymbol.randomWeighted()
        }

        applyDirectionalTransition(to: topImageView, newImage: nextTop.image, duration: transitionDuration)
        applyDirectionalTransition(to: centerImageView, newImage: nextCenter.image, duration: transitionDuration)
        applyDirectionalTransition(to: bottomImageView, newImage: nextBottom.image, duration: transitionDuration)

        DispatchQueue.main.asyncAfter(deadline: .now() + stepInterval) { [weak self] in
            self?.scheduleNextStep(token: token)
        }
    }

    private func applyDirectionalTransition(to imageView: UIImageView, newImage: UIImage?, duration: TimeInterval) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: .linear)
        transition.type = .push

        switch spinDirection {
        case .topToBottom:
            transition.subtype = .fromTop
        case .bottomToTop:
            transition.subtype = .fromBottom
        }

        imageView.layer.add(transition, forKey: "directionalSpin")
        imageView.image = newImage
    }

    private func stopSpinAndSettle() {
        guard isSpinning else { return }
        isSpinning = false

        let pool = SlotSymbol.allCases.filter { $0 != targetSymbol }
        let finalTop = pool.randomElement() ?? .cherry
        let finalBottom = pool.randomElement() ?? .lemon

        currentCenterSymbol = targetSymbol
        topImageView.image = finalTop.image
        centerImageView.image = targetSymbol.image
        bottomImageView.image = finalBottom.image

        topImageView.alpha = 0.85
        bottomImageView.alpha = 0.85

        SoundManager.shared.playReelStopFeedback()

        // Directional overshoot bounce: down (+8) or up (-8) depending on spin direction
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

    func stopSpin() {
        activeStepToken += 1
        isSpinning = false
    }

    func highlightWin() {
        layer.borderColor = ThemeColor.gold().cgColor
        layer.borderWidth = 3
        paylineIndicator.backgroundColor = ThemeColor.gold(alpha: 0.3)

        UIView.animate(
            withDuration: GameConfig.winAnimationDuration / 2,
            delay: 0,
            options: [.autoreverse, .repeat],
            animations: {
                self.centerImageView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }
        )
    }

    func clearHighlight() {
        centerImageView.layer.removeAllAnimations()
        centerImageView.transform = .identity
        layer.borderColor = ThemeColor.reelBorder(alpha: 0.7).cgColor
        layer.borderWidth = 2
        paylineIndicator.backgroundColor = ThemeColor.gold(alpha: 0.08)
    }
}
