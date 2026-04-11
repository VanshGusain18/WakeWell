import UIKit

class SleepRingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ringContainerView: UIView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ctaLabel: UILabel!
    
    @IBOutlet weak var chevronImageView: UIImageView!

    var onChevronTapped: (() -> Void)?

    private let backgroundLayer = CAShapeLayer()
    private let progressLayer    = CAShapeLayer()

    private var isExpanded: Bool = false

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupTextStyling()
        setupChevron()
        addChevronTapGesture()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawRing()
        applyShadow()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onChevronTapped = nil
    }

    // MARK: - Setup

    private func setupUI() {
        contentView.backgroundColor = .clear

        containerView.backgroundColor      = .systemBackground
        containerView.layer.cornerRadius   = 24
        containerView.clipsToBounds        = true
    }

    private func setupTextStyling() {
        scoreLabel.font          = UIFont.boldSystemFont(ofSize: 22)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor     = .label

        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.text = "YOUR SLEEP SCORE"

        subtitleLabel.font      = UIFont.systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = .label

        ctaLabel.font      = UIFont.systemFont(ofSize: 12)
        ctaLabel.textColor = .secondaryLabel
        ctaLabel.text      = "Tap to see today's detailed Sleep Score"
    }

    // MARK: - Chevron

    private func setupChevron() {
        chevronImageView.image       = UIImage(systemName: "chevron.down")
        chevronImageView.tintColor   = .secondaryLabel
        chevronImageView.contentMode = .center
    }

    private func addChevronTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(chevronTapped))
        chevronImageView.isUserInteractionEnabled = true
        chevronImageView.addGestureRecognizer(tap)
    }

    @objc private func chevronTapped() {
        onChevronTapped?()
    }

    func animateChevron(expanded: Bool) {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState],
            animations: {
                self.chevronImageView.transform =
                    expanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            }
        )
    }

    // MARK: - Ring drawing

    private func drawRing() {
        backgroundLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()

        let center = CGPoint(
            x: ringContainerView.bounds.width  / 2,
            y: ringContainerView.bounds.height / 2
        )
        let radius = min(
            ringContainerView.bounds.width,
            ringContainerView.bounds.height
        ) / 2 - 14

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )

        backgroundLayer.path        = path.cgPath
        backgroundLayer.strokeColor = UIColor.systemGray5.cgColor
        backgroundLayer.lineWidth   = 12
        backgroundLayer.fillColor   = UIColor.clear.cgColor
        ringContainerView.layer.addSublayer(backgroundLayer)

        progressLayer.path        = path.cgPath
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.lineWidth   = 12
        progressLayer.fillColor   = UIColor.clear.cgColor
        progressLayer.lineCap     = .round
        ringContainerView.layer.addSublayer(progressLayer)
    }

    // MARK: - Shadow

    private func applyShadow() {
        layer.masksToBounds  = false
        layer.shadowColor    = UIColor.black.cgColor
        layer.shadowOpacity  = 0.12
        layer.shadowRadius   = 10
        layer.shadowOffset   = CGSize(width: 0, height: 6)
        layer.shadowPath     = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 24
        ).cgPath
    }

    // MARK: - Configure

    func configure(with viewModel: SleepRingViewModel) {
        scoreLabel.text    = viewModel.scoreText
        subtitleLabel.text = viewModel.subtitleText

        progressLayer.strokeEnd = 0

        let animation                 = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue             = viewModel.progress
        animation.duration            = 0.9
        animation.timingFunction      = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode            = .forwards
        animation.isRemovedOnCompletion = false

        progressLayer.strokeEnd = viewModel.progress
        progressLayer.add(animation, forKey: "progress")
    }
}

