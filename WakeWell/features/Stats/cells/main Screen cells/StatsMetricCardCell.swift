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

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
        setupGestures()
    }

    private func setupUI() {
        // Title labels — secondary
        for lbl in [leftTitleLabel, rightTitleView] {
            lbl?.font      = .systemFont(ofSize: 14, weight: .medium)
            lbl?.textColor = WakeWellTheme.labelSecondary
        }
        // Value labels — gold accent matching screenshot
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

    private func setupGestures() {
        leftCardView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(leftCardTapped)))
        rightCardView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(rightCardTapped)))
    }

    func configure(leftTitle: String, leftValue: String, rightTitle: String?,
                   rightValue: String?, leftAction: (() -> Void)? = nil,
                   rightAction: (() -> Void)? = nil) {
        leftTitleLabel.text = leftTitle
        leftValueLabel.text = leftValue
        rightTitleView.text = rightTitle
        rightValueView.text = rightValue
        leftTapAction  = leftAction
        rightTapAction = rightAction
        rightCardView.alpha = (rightTitle == nil) ? 0 : 1
    }

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
