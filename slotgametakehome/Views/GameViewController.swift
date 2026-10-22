import UIKit

final class GameViewController: UIViewController {
    private let gameEngine = GameEngine()
    private var reels: [SlotReelView] = []
    private var spinResults: [SlotSymbol] = []

    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let creditsLabel = UILabel()
    private let betLabel = UILabel()
    private let betSegmentedControl = UISegmentedControl(items: ["1", "5", "10"])
    private let spinButton = UIButton(type: .system)
    private let resultLabel = UILabel()
    private let statsLabel = UILabel()
    private let winAnimationView = UIView()

    private var isSpinning = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.18, alpha: 1.0)

        setupBackground()
        setupTitle()
        setupReels()
        setupControls()
        setupLabels()
        setupConstraints()
    }

    private func setupBackground() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "reels-background-only")
        backgroundImageView.alpha = 0.3
        view.addSubview(backgroundImageView)
    }

    private func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "SLOT MACHINE"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowOpacity = 0.5
        titleLabel.layer.shadowRadius = 4
        view.addSubview(titleLabel)
    }

    private func setupReels() {
        let reelContainer = UIView()
        reelContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(reelContainer)

        for i in 0..<3 {
            let reel = SlotReelView()
            reel.translatesAutoresizingMaskIntoConstraints = false
            reel.delegate = self
            reelContainer.addSubview(reel)
            reels.append(reel)

            NSLayoutConstraint.activate([
                reel.topAnchor.constraint(equalTo: reelContainer.topAnchor),
                reel.bottomAnchor.constraint(equalTo: reelContainer.bottomAnchor),
                reel.widthAnchor.constraint(equalToConstant: 160),
                reel.heightAnchor.constraint(equalToConstant: 360)
            ])

            if i == 0 {
                reel.leadingAnchor.constraint(equalTo: reelContainer.leadingAnchor).isActive = true
            } else {
                reel.leadingAnchor.constraint(equalTo: reels[i-1].trailingAnchor, constant: 20).isActive = true
            }

            if i == 2 {
                reel.trailingAnchor.constraint(equalTo: reelContainer.trailingAnchor).isActive = true
            }
        }

        NSLayoutConstraint.activate([
            reelContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reelContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            reelContainer.widthAnchor.constraint(equalToConstant: 520),
            reelContainer.heightAnchor.constraint(equalToConstant: 360)
        ])
    }

    private func setupControls() {
        creditsLabel.translatesAutoresizingMaskIntoConstraints = false
        creditsLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
        creditsLabel.textColor = .white
        creditsLabel.textAlignment = .center
        view.addSubview(creditsLabel)

        betLabel.translatesAutoresizingMaskIntoConstraints = false
        betLabel.text = "BET"
        betLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        betLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        view.addSubview(betLabel)

        betSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        betSegmentedControl.selectedSegmentIndex = 0
        betSegmentedControl.addTarget(self, action: #selector(betChanged(_:)), for: .valueChanged)
        betSegmentedControl.selectedSegmentTintColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        betSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        betSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        view.addSubview(betSegmentedControl)

        spinButton.translatesAutoresizingMaskIntoConstraints = false
        spinButton.setTitle("SPIN", for: .normal)
        spinButton.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        spinButton.setTitleColor(.black, for: .normal)
        spinButton.setTitleColor(UIColor(white: 0.5, alpha: 1.0), for: .disabled)
        spinButton.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        spinButton.layer.cornerRadius = 30
        spinButton.layer.shadowColor = UIColor.black.cgColor
        spinButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        spinButton.layer.shadowOpacity = 0.3
        spinButton.layer.shadowRadius = 8
        spinButton.addTarget(self, action: #selector(spinTapped), for: .touchUpInside)
        view.addSubview(spinButton)

        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        resultLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        resultLabel.textAlignment = .center
        resultLabel.alpha = 0
        view.addSubview(resultLabel)

        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        statsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        statsLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
        statsLabel.textAlignment = .center
        statsLabel.numberOfLines = 2
        view.addSubview(statsLabel)
    }

    private func setupLabels() {
        winAnimationView.translatesAutoresizingMaskIntoConstraints = false
        winAnimationView.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.3)
        winAnimationView.layer.cornerRadius = 12
        winAnimationView.isHidden = true
        view.addSubview(winAnimationView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            creditsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            creditsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            creditsLabel.widthAnchor.constraint(equalToConstant: 200),

            betLabel.centerYAnchor.constraint(equalTo: creditsLabel.centerYAnchor),
            betLabel.trailingAnchor.constraint(equalTo: betSegmentedControl.leadingAnchor, constant: -12),

            betSegmentedControl.centerYAnchor.constraint(equalTo: creditsLabel.centerYAnchor),
            betSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            betSegmentedControl.widthAnchor.constraint(equalToConstant: 180),

            spinButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            spinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinButton.widthAnchor.constraint(equalToConstant: 200),
            spinButton.heightAnchor.constraint(equalToConstant: 60),

            resultLabel.bottomAnchor.constraint(equalTo: spinButton.topAnchor, constant: -20),
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            resultLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),

            statsLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 8),
            statsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            winAnimationView.leadingAnchor.constraint(equalTo: reels[0].leadingAnchor, constant: -10),
            winAnimationView.trailingAnchor.constraint(equalTo: reels[2].trailingAnchor, constant: 10),
            winAnimationView.topAnchor.constraint(equalTo: reels[0].topAnchor, constant: 110),
            winAnimationView.bottomAnchor.constraint(equalTo: reels[0].topAnchor, constant: 230)
        ])
    }

    private func updateUI() {
        let state = gameEngine.currentState
        creditsLabel.text = "CREDITS: \(state.credits)"
        betSegmentedControl.selectedSegmentIndex = betIndex(for: state.currentBet)
        spinButton.isEnabled = state.credits >= state.currentBet
        spinButton.alpha = spinButton.isEnabled ? 1.0 : 0.5
        updateStats()
    }

    private func betIndex(for bet: Int) -> Int {
        switch bet {
        case 1: return 0
        case 5: return 1
        case 10: return 2
        default: return 0
        }
    }

    private func betValue(for index: Int) -> Int {
        switch index {
        case 0: return 1
        case 1: return 5
        case 2: return 10
        default: return 1
        }
    }

    private func updateStats() {
        let state = gameEngine.currentState
        statsLabel.text = "Spins: \(state.totalSpins)  |  Biggest Win: \(state.biggestWin)  |  Total Won: \(state.totalWinnings)"
    }

    @objc private func betChanged(_ sender: UISegmentedControl) {
        let newBet = betValue(for: sender.selectedSegmentIndex)
        gameEngine.setBet(newBet)
        updateUI()
    }

    @objc private func spinTapped() {
        guard !isSpinning, gameEngine.canSpin() else { return }

        isSpinning = true
        spinButton.isEnabled = false
        spinButton.alpha = 0.5
        resultLabel.alpha = 0
        resultLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        winAnimationView.isHidden = true

        spinResults.removeAll()
        for reel in reels {
            reel.startSpin { [weak self] symbol in
                self?.spinResults.append(symbol)
                if self?.spinResults.count == 3 {
                    self?.handleSpinComplete()
                }
            }
        }
    }

    private func handleSpinComplete() {
        let result = gameEngine.spin()
        spinResults = result.symbols

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.showResult(result)
        }
    }

    private func showResult(_ result: SpinResult) {
        isSpinning = false
        updateUI()

        if result.isWin {
            resultLabel.text = "WIN! \(result.winAmount) CREDITS"
            resultLabel.textColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
            triggerWinAnimation()
        } else {
            resultLabel.text = "TRY AGAIN"
            resultLabel.textColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        }

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.resultLabel.alpha = 1
            self.resultLabel.transform = .identity
        }

        spinButton.isEnabled = gameEngine.canSpin()
        spinButton.alpha = spinButton.isEnabled ? 1.0 : 0.5
        updateStats()
    }

    private func triggerWinAnimation() {
        winAnimationView.isHidden = false
        winAnimationView.alpha = 0

        UIView.animate(withDuration: 0.2, animations: {
            self.winAnimationView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                self.winAnimationView.alpha = 0
            }) { _ in
                self.winAnimationView.isHidden = true
            }
        }

        for reel in reels {
            let originalTransform = reel.transform
            UIView.animate(withDuration: 0.1, animations: {
                reel.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    reel.transform = originalTransform
                }
            }
        }
    }
}

extension GameViewController: SlotReelViewDelegate {
    func reelDidFinishSpinning(_ reel: SlotReelView, finalSymbol: SlotSymbol) {
    }
}