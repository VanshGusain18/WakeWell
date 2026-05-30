import UIKit

final class SleepDebtViewCardCell: UICollectionViewCell {

    static let identifier = "SleepDebtViewCardCell"

    @IBOutlet private weak var sleepIconContainerView: UIView!
    @IBOutlet private weak var sleepIconImageView: UIImageView!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    var onClose: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        addSwipeGesture()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onClose = nil
    }

    private func setupUI() {
        contentView.backgroundColor = WakeWellTheme.cardBackground
        contentView.subviews.first?.backgroundColor = WakeWellTheme.cardBackground
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        layer.masksToBounds = false
        layer.shadowColor = WakeWellTheme.shadowColor.cgColor
        layer.shadowOpacity = WakeWellTheme.shadowOpacity
        layer.shadowRadius = WakeWellTheme.shadowRadius
        layer.shadowOffset = WakeWellTheme.shadowOffset

        sleepIconContainerView.layer.cornerRadius = 14
        sleepIconContainerView.layer.masksToBounds = true
        sleepIconContainerView.backgroundColor = WakeWellTheme.purpleTint

        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        sleepIconImageView.image = UIImage(systemName: "bed.double.fill", withConfiguration: config)
        sleepIconImageView.tintColor = WakeWellTheme.accentPurple
        sleepIconImageView.contentMode = .scaleAspectFit

        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = WakeWellTheme.labelPrimary
        valueLabel.numberOfLines = 1

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.numberOfLines = 4
    }

    private func addSwipeGesture() {
        contentView.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        )
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let tx = gesture.translation(in: self).x
        let vx = gesture.velocity(in: self).x

        switch gesture.state {
        case .changed:
            let cx = tx > 0 ? tx : tx * 0.3
            contentView.transform = CGAffineTransform(translationX: cx, y: 0)
            contentView.alpha = 1.0 - min(abs(cx) / (bounds.width * 0.5), 1.0) * 0.6
        case .ended, .cancelled:
            if abs(tx) > bounds.width * 0.4 || abs(vx) > 800 {
                dismissWithAnimation()
            } else {
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 0.5
                ) {
                    self.contentView.transform = .identity
                    self.contentView.alpha = 1
                }
            }
        default:
            break
        }
    }

    private func dismissWithAnimation() {
        let dir: CGFloat = contentView.transform.tx >= 0 ? 1 : -1
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.contentView.transform = CGAffineTransform(
                translationX: dir * self.bounds.width * 1.5,
                y: 0
            )
            self.contentView.alpha = 0
        }, completion: { _ in
            self.onClose?()
        })
    }

    func configure(with viewModel: SleepDebtViewModel) {
        let state = viewModel.cardState
        valueLabel.text = state.valueText

        let subtitleParts = [state.trendText, state.insightText]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        subtitleLabel.text = subtitleParts.joined(separator: " · ")
        subtitleLabel.textColor = subtitleColor(for: state)
    }

    private func subtitleColor(for state: SleepDebtViewModel.CardState) -> UIColor {
        if state.tone == .negative {
            return .systemRed
        }

        if state.valueText.hasPrefix("0") || state.trendText == nil {
            return WakeWellTheme.accentGold
        }

        return .systemGreen
    }
}
