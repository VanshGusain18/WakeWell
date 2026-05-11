import UIKit

class SleepRingCollectionViewCell: UICollectionViewCell {

    static let identifier = "SleepRingCollectionViewCell"

    @IBOutlet weak var containerView:     UIView!
    @IBOutlet weak var ringContainerView: UIView!
    @IBOutlet weak var scoreLabel:        UILabel!
    @IBOutlet weak var titleLabel:        UILabel!
    @IBOutlet weak var subtitleLabel:     UILabel!
    @IBOutlet weak var ctaLabel:          UILabel!
    @IBOutlet weak var chevronImageView:  UIImageView!

    var onChevronTapped: (() -> Void)?

    private let backgroundRingLayer = CAShapeLayer()
    private let progressRingLayer   = CAShapeLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLabels()
        setupChevron()
        addChevronTapGesture()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawRing()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }

    override func prepareForReuse() { super.prepareForReuse(); onChevronTapped = nil }

    // ── Card ───────────────────────────────────────────────────────────────
    private func setupUI() {
        contentView.backgroundColor       = .clear
        containerView.backgroundColor     = WakeWellTheme.cardBackground
        ringContainerView.backgroundColor = .clear
        containerView.layer.cornerRadius  = 20
        containerView.layer.masksToBounds = true
        layer.masksToBounds  = false
        layer.shadowColor    = WakeWellTheme.shadowColor.cgColor
        layer.shadowOpacity  = WakeWellTheme.shadowOpacity
        layer.shadowRadius   = WakeWellTheme.shadowRadius
        layer.shadowOffset   = WakeWellTheme.shadowOffset
    }

    // ── Labels ─────────────────────────────────────────────────────────────
    private func setupLabels() {
        titleLabel?.font       = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel?.textColor  = WakeWellTheme.labelSecondary
        titleLabel?.textAlignment = .center
        titleLabel?.text       = "YOUR SLEEP SCORE"

        scoreLabel?.font       = .boldSystemFont(ofSize: 28)
        scoreLabel?.textColor  = WakeWellTheme.labelPrimary
        scoreLabel?.textAlignment = .center

        subtitleLabel?.font      = .systemFont(ofSize: 14, weight: .semibold)
        subtitleLabel?.textColor = WakeWellTheme.labelPrimary
        subtitleLabel?.textAlignment = .center

        ctaLabel?.font       = .systemFont(ofSize: 10)
        ctaLabel?.textColor  = WakeWellTheme.labelSecondary
        ctaLabel?.textAlignment = .center
        ctaLabel?.numberOfLines = 2
        ctaLabel?.text       = "Tap for detailed sleep score"
    }

    // ── Chevron ────────────────────────────────────────────────────────────
    private func setupChevron() {
        chevronImageView?.image       = UIImage(systemName: "chevron.down")
        chevronImageView?.tintColor   = WakeWellTheme.labelSecondary
        chevronImageView?.contentMode = .scaleAspectFit
    }

    private func addChevronTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(chevronTapped))
        chevronImageView?.isUserInteractionEnabled = true
        chevronImageView?.addGestureRecognizer(tap)
    }

    @objc private func chevronTapped() { onChevronTapped?() }

    func animateChevron(expanded: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.chevronImageView?.transform =
                expanded ? CGAffineTransform(rotationAngle: .pi) : .identity
        }
    }

    // ── Ring ───────────────────────────────────────────────────────────────
    private func drawRing() {
        guard let rc = ringContainerView, rc.bounds.width > 0 else { return }
        backgroundRingLayer.removeFromSuperlayer()
        progressRingLayer.removeFromSuperlayer()

        let center = CGPoint(x: rc.bounds.midX, y: rc.bounds.midY)
        let radius = min(rc.bounds.width, rc.bounds.height) / 2 - 10
        guard radius > 0 else { return }

        let path = UIBezierPath(arcCenter: center, radius: radius,
                                startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true)

        backgroundRingLayer.path        = path.cgPath
        backgroundRingLayer.strokeColor = WakeWellTheme.border.cgColor
        backgroundRingLayer.lineWidth   = 10
        backgroundRingLayer.fillColor   = UIColor.clear.cgColor
        rc.layer.addSublayer(backgroundRingLayer)

        // Purple ring — matches screenshot
        progressRingLayer.path        = path.cgPath
        progressRingLayer.strokeColor = WakeWellTheme.accentPurple.cgColor
        progressRingLayer.lineWidth   = 10
        progressRingLayer.fillColor   = UIColor.clear.cgColor
        progressRingLayer.lineCap     = .round
        rc.layer.addSublayer(progressRingLayer)
    }

    // ── Configure (logic unchanged) ────────────────────────────────────────
    func configure(with viewModel: SleepRingViewModel) {
        titleLabel?.text    = "YOUR SLEEP SCORE"
        scoreLabel?.text    = viewModel.scoreText
        subtitleLabel?.text = viewModel.subtitleText

        progressRingLayer.strokeEnd = 0
        if !viewModel.hasData {
            progressRingLayer.removeAllAnimations()
            progressRingLayer.strokeEnd = 0
            return
        }
        let anim                    = CABasicAnimation(keyPath: "strokeEnd")
        anim.toValue                = viewModel.progress
        anim.duration               = 0.9
        anim.timingFunction         = CAMediaTimingFunction(name: .easeInEaseOut)
        anim.fillMode               = .forwards
        anim.isRemovedOnCompletion  = false
        progressRingLayer.strokeEnd = viewModel.progress
        progressRingLayer.add(anim, forKey: "progress")
    }
}
