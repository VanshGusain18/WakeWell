import UIKit

class StatsMetricCardCell: UITableViewCell {

    @IBOutlet weak var leftCardView:   UIView!
    @IBOutlet weak var leftTitleLabel: UILabel!
    @IBOutlet weak var leftValueLabel: UILabel!
    @IBOutlet weak var rightCardView:  UIView!
    @IBOutlet weak var rightTitleView: UILabel!
    @IBOutlet weak var rightValueView: UILabel!

    var leftTapAction:  (() -> Void)?
    var rightTapAction: (() -> Void)?

    // Trend labels added programmatically — no XIB change needed
    private let leftTrendLabel  = UILabel()
    private let rightTrendLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupTrendLabels()
        setupGestures()
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        for lbl in [leftTitleLabel, rightTitleView] {
            lbl?.font      = .systemFont(ofSize: 14, weight: .medium)
            lbl?.textColor = WakeWellTheme.labelSecondary
        }
        for lbl in [leftValueLabel, rightValueView] {
            lbl?.font      = .systemFont(ofSize: 26, weight: .semibold)
            lbl?.textColor = WakeWellTheme.accentGold
        }
        styleCard(leftCardView)
        styleCard(rightCardView)
    }

    private func styleCard(_ card: UIView) {
        card.backgroundColor      = WakeWellTheme.cardBackground
        card.layer.cornerRadius   = 20
        card.isUserInteractionEnabled = true
        card.layer.borderWidth    = 0.5
        card.layer.borderColor    = WakeWellTheme.border.cgColor
        card.layer.shadowColor    = WakeWellTheme.shadowColor.cgColor
        card.layer.shadowOpacity  = 0.10
        card.layer.shadowOffset   = CGSize(width: 0, height: 6)
        card.layer.shadowRadius   = 12
        card.layer.masksToBounds  = false
    }

    // Pin a small trend label to the bottom-right of each card
    private func setupTrendLabels() {
        for (trendLabel, card) in [(leftTrendLabel, leftCardView!),
                                    (rightTrendLabel, rightCardView!)] {
            trendLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            trendLabel.textAlignment = .right
            trendLabel.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(trendLabel)
            NSLayoutConstraint.activate([
                trendLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
                trendLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10)
            ])
        }
    }

    private func setupGestures() {
        leftCardView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(leftCardTapped)))
        rightCardView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(rightCardTapped)))
    }

    // MARK: - Configure

    func configure(leftTitle: String, leftValue: String, leftTrend: Int = 0,
                   rightTitle: String?, rightValue: String?, rightTrend: Int = 0,
                   leftAction: (() -> Void)? = nil, rightAction: (() -> Void)? = nil) {
        leftTitleLabel.text = leftTitle
        leftValueLabel.text = leftValue
        applyTrend(leftTrend, to: leftTrendLabel)

        rightTitleView.text = rightTitle
        rightValueView.text = rightValue
        applyTrend(rightTrend, to: rightTrendLabel)

        leftTapAction  = leftAction
        rightTapAction = rightAction
        rightCardView.alpha = (rightTitle == nil) ? 0 : 1
    }

    // MARK: - Trend helper

    private func applyTrend(_ percent: Int, to label: UILabel) {
        if percent > 0 {
            label.text      = "↑ \(percent)%"
            label.textColor = .systemGreen
        } else if percent < 0 {
            label.text      = "↓ \(abs(percent))%"
            label.textColor = .systemRed
        } else {
            label.text      = "→ 0%"
            label.textColor = WakeWellTheme.labelTertiary
        }
    }

    // MARK: - Actions

    @objc private func leftCardTapped() {
        UISelectionFeedbackGenerator().selectionChanged()
        animateInteraction(leftCardView)
        leftTapAction?()
    }

    @objc private func rightCardTapped() {
        UISelectionFeedbackGenerator().selectionChanged()
        animateInteraction(rightCardView)
        rightTapAction?()
    }

    private func animateInteraction(_ view: UIView) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            view.transform = CGAffineTransform(scaleX: 0.94, y: 0.94); view.alpha = 0.8
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
                view.transform = .identity; view.alpha = 1
            }, completion: nil)
        })
    }
}
