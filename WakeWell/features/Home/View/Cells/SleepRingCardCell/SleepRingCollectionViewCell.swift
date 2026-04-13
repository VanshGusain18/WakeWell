import UIKit

class SleepRingCollectionViewCell: UICollectionViewCell {

    static let identifier = "SleepRingCollectionViewCell"

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ringContainerView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ctaLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!

    var onChevronTapped: (() -> Void)?

    private let backgroundRingLayer = CAShapeLayer()
    private let progressRingLayer   = CAShapeLayer()

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLabels()
        setupChevron()
        addChevronTapGesture()
        setupUI()
        applyStyling()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawRing()
        applyShadowPath()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onChevronTapped = nil
    }

    // MARK: - Labels

    private func setupLabels() {
        titleLabel?.font          = UIFont.systemFont(ofSize: 11, weight: .semibold)
        titleLabel?.textColor     = .secondaryLabel
        titleLabel?.textAlignment = .center
        titleLabel?.text          = "YOUR SLEEP SCORE"

        scoreLabel?.font          = UIFont.boldSystemFont(ofSize: 28)
        scoreLabel?.textColor     = .label
        scoreLabel?.textAlignment = .center

        subtitleLabel?.font          = UIFont.systemFont(ofSize: 14, weight: .semibold)
        subtitleLabel?.textColor     = .label
        subtitleLabel?.textAlignment = .center

        ctaLabel?.font          = UIFont.systemFont(ofSize: 10)
        ctaLabel?.textColor     = .secondaryLabel
        ctaLabel?.textAlignment = .center
        ctaLabel?.numberOfLines = 2
        ctaLabel?.text          = "Tap for detailed sleep score"
    }

    // MARK: - Chevron

    private func setupChevron() {
        chevronImageView?.image       = UIImage(systemName: "chevron.down")
        chevronImageView?.tintColor   = .secondaryLabel
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

    // MARK: - Ring

    private func drawRing() {
        guard let rc = ringContainerView, rc.bounds.width > 0 else { return }
        backgroundRingLayer.removeFromSuperlayer()
        progressRingLayer.removeFromSuperlayer()

        let center = CGPoint(x: rc.bounds.midX, y: rc.bounds.midY)
        let radius = min(rc.bounds.width, rc.bounds.height) / 2 - 10
        guard radius > 0 else { return }

        let path = UIBezierPath(arcCenter: center, radius: radius,
                                startAngle: -.pi / 2, endAngle: 1.5 * .pi,
                                clockwise: true)

        backgroundRingLayer.path        = path.cgPath
        backgroundRingLayer.strokeColor = UIColor.systemGray5.cgColor
        backgroundRingLayer.lineWidth   = 10
        backgroundRingLayer.fillColor   = UIColor.clear.cgColor
        rc.layer.addSublayer(backgroundRingLayer)

        progressRingLayer.path        = path.cgPath
        progressRingLayer.strokeColor = UIColor.systemBlue.cgColor
        progressRingLayer.lineWidth   = 10
        progressRingLayer.fillColor   = UIColor.clear.cgColor
        progressRingLayer.lineCap     = .round
        rc.layer.addSublayer(progressRingLayer)
    }

    // MARK: - Styling

    private func setupUI() {
        contentView.backgroundColor       = .clear
        containerView.layer.cornerRadius  = 20
        containerView.layer.masksToBounds = true
        containerView.backgroundColor     = .systemBackground
        layer.masksToBounds               = false
    }

    private func applyStyling() {
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius  = 10
        layer.shadowOffset  = CGSize(width: 0, height: 4)
    }

    private func applyShadowPath() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }

    // MARK: - Configure

    func configure(with viewModel: SleepRingViewModel) {
        titleLabel?.text    = "YOUR SLEEP SCORE"
        scoreLabel?.text    = viewModel.scoreText
        subtitleLabel?.text = viewModel.subtitleText

        progressRingLayer.strokeEnd = 0
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
