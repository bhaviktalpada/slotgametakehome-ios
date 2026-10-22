import UIKit

protocol SlotReelViewDelegate: AnyObject {
    func reelDidFinishSpinning(_ reel: SlotReelView, finalSymbol: SlotSymbol)
}

final class SlotReelView: UIView {
    weak var delegate: SlotReelViewDelegate?

    private let symbolSize: CGSize = CGSize(width: 120, height: 120)
    private let visibleSymbols = 3
    private var symbolImageViews: [UIImageView] = []
    private var currentSymbolIndex = 0
    private var isSpinning = false
    private var spinTimer: Timer?
    private var finalSymbol: SlotSymbol?
    private var spinCount = 0
    private let totalSpins = 20

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        clipsToBounds = true
        backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        layer.cornerRadius = 12
        layer.borderWidth = 2
        layer.borderColor = UIColor(white: 0.3, alpha: 1.0).cgColor

        for i in 0..<visibleSymbols {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            symbolImageViews.append(imageView)

            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                imageView.widthAnchor.constraint(equalToConstant: symbolSize.width),
                imageView.heightAnchor.constraint(equalToConstant: symbolSize.height),
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat(i) * symbolSize.height)
            ])
        }

        setInitialSymbols()
    }

    private func setInitialSymbols() {
        for (index, imageView) in symbolImageViews.enumerated() {
            let symbol = SlotSymbol.allCases[index % SlotSymbol.allCases.count]
            imageView.image = symbol.image
        }
    }

    func startSpin(completion: @escaping (SlotSymbol) -> Void) {
        guard !isSpinning else { return }
        isSpinning = true
        spinCount = 0
        finalSymbol = SlotSymbol.randomWeighted()

        spinTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            self?.performSpinStep(timer: timer, completion: completion)
        }
    }

    private func performSpinStep(timer: Timer, completion: @escaping (SlotSymbol) -> Void) {
        guard let finalSymbol = finalSymbol else { return }

        spinCount += 1

        for (index, imageView) in symbolImageViews.enumerated() {
            let symbol: SlotSymbol
            if spinCount >= totalSpins - 5 && index == 1 {
                symbol = finalSymbol
            } else {
                symbol = SlotSymbol.randomWeighted()
            }

            UIView.transition(with: imageView, duration: 0.03, options: .transitionCrossDissolve) {
                imageView.image = symbol.image
            }
        }

        if spinCount >= totalSpins {
            timer.invalidate()
            spinTimer = nil
            isSpinning = false

            symbolImageViews[1].image = finalSymbol.image
            delegate?.reelDidFinishSpinning(self, finalSymbol: finalSymbol)
            completion(finalSymbol)
        }
    }

    func stopSpin() {
        spinTimer?.invalidate()
        spinTimer = nil
        isSpinning = false
    }

    var spinning: Bool {
        return isSpinning
    }
}