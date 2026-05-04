import UIKit

class RiseRitualCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconImageView:     UIImageView!
    @IBOutlet weak var titleLabel:        UILabel!
    @IBOutlet weak var categoryLabel:     UILabel!
    @IBOutlet weak var startButton:       UIButton!
    @IBOutlet weak var closeButton:       UIButton!
    
    static let identifier = "RiseRitualCollectionViewCell"
    
    var onClose:       (() -> Void)?
    var onStartRitual: (() -> Void)?
    private var didInstallCompactLayout = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCard()
        setupLabels()
        setupButtons()
        setupCompactLayout()
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSwipeGesture()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 24).cgPath
    }
    
    // ── Card ───────────────────────────────────────────────────────────────
    private func setupCard() {
        contentView.backgroundColor     = WakeWellTheme.cardBackground
        contentView.subviews.first?.backgroundColor = WakeWellTheme.cardBackground
        contentView.layer.cornerRadius  = 24
        contentView.layer.masksToBounds = true
        layer.masksToBounds  = false
        layer.shadowColor    = WakeWellTheme.shadowColor.cgColor
        layer.shadowOpacity  = WakeWellTheme.shadowOpacity
        layer.shadowRadius   = WakeWellTheme.shadowRadius
        layer.shadowOffset   = WakeWellTheme.shadowOffset
    }
    
    // ── Labels ─────────────────────────────────────────────────────────────
    private func setupLabels() {
        titleLabel.font           = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor      = WakeWellTheme.labelPrimary
        titleLabel.numberOfLines  = 1
        
        // Category pill: gold to match sun icon
        categoryLabel.font           = .systemFont(ofSize: 11, weight: .semibold)
        categoryLabel.textColor      = WakeWellTheme.accentGold
        categoryLabel.numberOfLines  = 1
    }
    
    // ── Buttons ────────────────────────────────────────────────────────────
    private func setupButtons() {
        // Icon container: gold tint (sun colour)
        iconContainerView.backgroundColor    = WakeWellTheme.accentGold.withAlphaComponent(0.15)
        iconContainerView.layer.cornerRadius = 12
        iconContainerView.clipsToBounds      = true
        iconImageView.tintColor   = WakeWellTheme.accentGold   // gold sun
        iconImageView.contentMode = .scaleAspectFit
        
        startButton.configuration = nil
        startButton.backgroundColor = WakeWellTheme.accentGold
        startButton.setTitle(nil, for: .normal)
        startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        startButton.tintColor = .white
        startButton.layer.cornerRadius = 18
        startButton.clipsToBounds = true
        startButton.accessibilityLabel = "Start ritual"
        
        closeButton.configuration = nil
        closeButton.tintColor = WakeWellTheme.labelTertiary
        closeButton.setTitle(nil, for: .normal)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
    }

    private func setupCompactLayout() {
        guard !didInstallCompactLayout,
              let cardView = contentView.subviews.first else {
            return
        }

        didInstallCompactLayout = true
        cardView.constraints.forEach { constraint in
            let firstView = constraint.firstItem as? UIView
            let secondView = constraint.secondItem as? UIView
            if firstView == startButton || secondView == startButton ||
                firstView == closeButton || secondView == closeButton {
                constraint.isActive = false
            }
        }

        [
            iconContainerView,
            iconImageView,
            titleLabel,
            categoryLabel,
            startButton,
            closeButton
        ].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            iconContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 52),
            iconContainerView.heightAnchor.constraint(equalToConstant: 52),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),

            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),

            startButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            startButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 36),
            startButton.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: startButton.leadingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 22),

            categoryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            categoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: startButton.leadingAnchor, constant: -12),
            categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
    }
    
    // ── Swipe gesture (logic unchanged) ───────────────────────────────────
    private func addSwipeGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        contentView.addGestureRecognizer(pan)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity    = gesture.velocity(in: self)
        switch gesture.state {
        case .changed:
            let clampedX = translation.x > 0 ? translation.x : translation.x * 0.3
            contentView.transform = CGAffineTransform(translationX: clampedX, y: 0)
            contentView.alpha = 1.0 - min(abs(clampedX) / (bounds.width * 0.5), 1.0) * 0.6
        case .ended, .cancelled:
            if abs(translation.x) > bounds.width * 0.4 || abs(velocity.x) > 800 {
                dismissWithAnimation()
            } else {
                UIView.animate(withDuration: 0.3, delay: 0,
                               usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                    self.contentView.transform = .identity
                    self.contentView.alpha     = 1.0
                }
            }
        default: break
        }
    }
    
    private func dismissWithAnimation() {
        let direction: CGFloat = contentView.transform.tx >= 0 ? 1 : -1
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.contentView.transform = CGAffineTransform(
                translationX: direction * self.bounds.width * 1.5, y: 0)
            self.contentView.alpha = 0
        }, completion: { _ in self.onClose?() })
    }
    
    @objc private func closeTapped() { dismissWithAnimation() }

    @objc private func startTapped() { onStartRitual?() }
    
    // ── Configure ─────────────────────────────────────────────────────────
    func configure(with viewModel: RiseRitualViewModel) {
        titleLabel.text       = viewModel.title
        categoryLabel.text    = viewModel.category
        startButton.configuration = nil
        startButton.setTitle(nil, for: .normal)
        startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        closeButton.configuration = nil
        closeButton.setTitle(nil, for: .normal)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
    }
    @IBAction func startButtonfunction(_ sender: Any) { startTapped() }
}
