import UIKit

class RiseRitualCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconImageView:     UIImageView!
    @IBOutlet weak var titleLabel:        UILabel!
    @IBOutlet weak var categoryLabel:     UILabel!
    @IBOutlet weak var descriptionLabel:  UILabel!
    @IBOutlet weak var startButton:       UIButton!
    @IBOutlet weak var closeButton:       UIButton!
    
    static let identifier = "RiseRitualCollectionViewCell"
    
    var onClose:       (() -> Void)?
    var onStartRitual: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCard()
        setupLabels()
        setupButtons()
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
        
        descriptionLabel.font          = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor     = WakeWellTheme.labelSecondary
        descriptionLabel.numberOfLines = 0
    }
    
    // ── Buttons ────────────────────────────────────────────────────────────
    private func setupButtons() {
        // Icon container: gold tint (sun colour)
        iconContainerView.backgroundColor    = WakeWellTheme.accentGold.withAlphaComponent(0.15)
        iconContainerView.layer.cornerRadius = 12
        iconContainerView.clipsToBounds      = true
        iconImageView.tintColor   = WakeWellTheme.accentGold   // gold sun
        iconImageView.contentMode = .scaleAspectFit
        
        // Gold CTA — "Start Ritual"
        WakeWellTheme.stylePrimaryButton(startButton)
        startButton.setTitle("Start Ritual", for: .normal)
        startButton.tintColor = WakeWellTheme.accentPurple
        
        closeButton.tintColor = WakeWellTheme.labelTertiary
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
    
    // ── Configure ─────────────────────────────────────────────────────────
    func configure(with viewModel: RiseRitualViewModel) {
        titleLabel.text       = viewModel.title
        categoryLabel.text    = viewModel.category
        descriptionLabel.text = viewModel.description
        startButton.setTitle(viewModel.startButtonTitle, for: .normal)
        
    }
    @IBAction func startButtonfunction(_ sender: Any) { onStartRitual?() }
}
