import UIKit

class SleepDebtViewCardCell: UICollectionViewCell {

    static let identifier = "SleepDebtViewCardCell"

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var closeButton:  UIButton!

    var onClose: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSwipeGesture()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }

    private func setupUI() {
        contentView.backgroundColor     = WakeWellTheme.cardBackground
        contentView.layer.cornerRadius  = 20
        contentView.layer.masksToBounds = true
        layer.masksToBounds  = false
        layer.shadowColor    = WakeWellTheme.shadowColor.cgColor
        layer.shadowOpacity  = WakeWellTheme.shadowOpacity
        layer.shadowRadius   = WakeWellTheme.shadowRadius
        layer.shadowOffset   = WakeWellTheme.shadowOffset

        messageLabel.font          = .systemFont(ofSize: 15, weight: .semibold)
        messageLabel.numberOfLines = 0
        messageLabel.textColor     = WakeWellTheme.labelPrimary
        closeButton.tintColor      = WakeWellTheme.labelTertiary
    }

    // ── Swipe (logic unchanged) ────────────────────────────────────────────
    private func addSwipeGesture() {
        contentView.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
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
            if abs(tx) > bounds.width * 0.4 || abs(vx) > 800 { dismissWithAnimation() }
            else {
                UIView.animate(withDuration: 0.3, delay: 0,
                               usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                    self.contentView.transform = .identity; self.contentView.alpha = 1
                }
            }
        default: break
        }
    }

    private func dismissWithAnimation() {
        let dir: CGFloat = contentView.transform.tx >= 0 ? 1 : -1
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.contentView.transform = CGAffineTransform(
                translationX: dir * self.bounds.width * 1.5, y: 0)
            self.contentView.alpha = 0
        }, completion: { _ in self.onClose?() })
    }

    @objc private func closeTapped() { dismissWithAnimation() }

    // ── Configure — highlight hours in gold ───────────────────────────────
    func configure(with viewModel: SleepDebtViewModel) {
        let text = viewModel.debtMessage()
        let attr = NSMutableAttributedString(
            string: text,
            attributes: [.foregroundColor: WakeWellTheme.labelPrimary,
                         .font: UIFont.systemFont(ofSize: 15, weight: .semibold)])
        // Colour numbers + "hrs" in gold to match screenshot
        if let regex = try? NSRegularExpression(pattern: #"[0-9]+\.?[0-9]* hrs?"#) {
            regex.enumerateMatches(in: text, range: NSRange(text.startIndex..., in: text)) { m, _, _ in
                if let r = m?.range {
                    attr.addAttribute(.foregroundColor, value: WakeWellTheme.accentGold, range: r)
                }
            }
        }
        messageLabel.attributedText = attr
    }
}
