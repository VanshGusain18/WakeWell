import UIKit

final class SleepRingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "SleepRingCollectionViewCell"
    
    var onChevronTapped: (() -> Void)?
    
    private let containerView = UIView()
    private let ringContainerView = UIView()
    private let scoreLabel = UILabel()
    private let titleLabel = UILabel()
    private let ctaLabel = UILabel()
    private let chevronImageView = UIImageView()
    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 24).cgPath
        drawRing()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 24
        containerView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 14
        layer.shadowOffset = CGSize(width: 0, height: 8)
        
        ringContainerView.translatesAutoresizingMaskIntoConstraints = false
        ringContainerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
        ringContainerView.layer.cornerRadius = 40
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.font = .systemFont(ofSize: 26, weight: .bold)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .label
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "SLEEP SCORE"
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        
        ctaLabel.translatesAutoresizingMaskIntoConstraints = false
        ctaLabel.text = "Tap to see details"
        ctaLabel.font = .systemFont(ofSize: 13, weight: .medium)
        ctaLabel.textColor = .secondaryLabel
        ctaLabel.numberOfLines = 2
        
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.down")
        chevronImageView.tintColor = .secondaryLabel
        chevronImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chevronImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(chevronTapped))
        chevronImageView.addGestureRecognizer(tap)
        
        contentView.addSubview(containerView)
        containerView.addSubview(chevronImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(ringContainerView)
        ringContainerView.addSubview(scoreLabel)
        containerView.addSubview(ctaLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            chevronImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 20),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8),
            
            ringContainerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            ringContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            ringContainerView.widthAnchor.constraint(equalToConstant: 80),
            ringContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            scoreLabel.centerXAnchor.constraint(equalTo: ringContainerView.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: ringContainerView.centerYAnchor),
            
            ctaLabel.topAnchor.constraint(equalTo: ringContainerView.bottomAnchor, constant: 14),
            ctaLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            ctaLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            ctaLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func chevronTapped() {
        onChevronTapped?()
    }
    
    private func drawRing() {
        backgroundLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()
        
        let center = CGPoint(x: ringContainerView.bounds.midX, y: ringContainerView.bounds.midY)
        let radius = min(ringContainerView.bounds.width, ringContainerView.bounds.height) / 2 - 8
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        
        backgroundLayer.path = path.cgPath
        backgroundLayer.strokeColor = UIColor.systemGray5.cgColor
        backgroundLayer.lineWidth = 10
        backgroundLayer.fillColor = UIColor.clear.cgColor
        
        progressLayer.path = path.cgPath
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.lineWidth = 10
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        
        ringContainerView.layer.addSublayer(backgroundLayer)
        ringContainerView.layer.addSublayer(progressLayer)
    }
    
    func configure(with viewModel: SleepRingViewModel, isExpanded: Bool) {
        scoreLabel.text = viewModel.scoreText
        setExpanded(isExpanded, animated: false)
        
        progressLayer.strokeEnd = 0
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = viewModel.progress
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        progressLayer.strokeEnd = viewModel.progress
        progressLayer.add(animation, forKey: "progress")
    }
    
    func setExpanded(_ expanded: Bool, animated: Bool) {
        let changes = {
            self.chevronImageView.transform = expanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            self.ctaLabel.textColor = expanded ? .systemBlue : .secondaryLabel
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.2,
                options: [.curveEaseInOut, .allowUserInteraction],
                animations: changes
            )
        } else {
            changes()
        }
    }
}
