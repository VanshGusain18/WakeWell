import UIKit

final class RiseRitualCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "RiseRitualCollectionViewCell"
    
    var onDismissRequested: ((RiseRitualCollectionViewCell) -> Void)?
    var onStartTapped: (() -> Void)?
    var onViewRiseTapped: (() -> Void)?
    
    private let symbolContainerView = UIView()
    private let symbolImageView = UIImageView()
    private let titleLabel = UILabel()
    private let eyebrowLabel = UILabel()
    private let messageLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let primaryButton = UIButton(type: .system)
    private let secondaryButton = UIButton(type: .system)
    private let headerStack = UIStackView()
    private let textStack = UIStackView()
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    private var isDismissing = false
    
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
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 28).cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isDismissing = false
        transform = .identity
        alpha = 1
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.08)
        contentView.layer.cornerRadius = 28
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.systemOrange.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 22
        layer.shadowOffset = CGSize(width: 0, height: 10)
        
        contentView.addGestureRecognizer(panGestureRecognizer)
        
        symbolContainerView.translatesAutoresizingMaskIntoConstraints = false
        symbolContainerView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
        symbolContainerView.layer.cornerRadius = 16
        
        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        symbolImageView.tintColor = .systemOrange
        symbolImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        
        eyebrowLabel.translatesAutoresizingMaskIntoConstraints = false
        eyebrowLabel.font = .systemFont(ofSize: 12, weight: .bold)
        eyebrowLabel.textColor = .systemBrown
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .secondaryLabel
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.configuration = .filled()
        primaryButton.configuration?.cornerStyle = .capsule
        primaryButton.configuration?.baseBackgroundColor = .systemOrange
        primaryButton.configuration?.baseForegroundColor = .white
        primaryButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
        secondaryButton.configuration = .plain()
        secondaryButton.configuration?.baseForegroundColor = .systemBrown
        secondaryButton.configuration?.image = UIImage(systemName: "chevron.right")
        secondaryButton.configuration?.imagePlacement = .trailing
        secondaryButton.configuration?.imagePadding = 6
        secondaryButton.addTarget(self, action: #selector(viewRiseTapped), for: .touchUpInside)
        
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.spacing = 14
        headerStack.alignment = .top
        
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(eyebrowLabel)
        
        headerStack.addArrangedSubview(symbolContainerView)
        headerStack.addArrangedSubview(textStack)
        headerStack.addArrangedSubview(closeButton)
        
        contentView.addSubview(headerStack)
        symbolContainerView.addSubview(symbolImageView)
        contentView.addSubview(messageLabel)
        contentView.addSubview(primaryButton)
        contentView.addSubview(secondaryButton)
        
        NSLayoutConstraint.activate([
            symbolContainerView.widthAnchor.constraint(equalToConstant: 48),
            symbolContainerView.heightAnchor.constraint(equalToConstant: 48),
            
            symbolImageView.centerXAnchor.constraint(equalTo: symbolContainerView.centerXAnchor),
            symbolImageView.centerYAnchor.constraint(equalTo: symbolContainerView.centerYAnchor),
            
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),
            
            headerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 18),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            primaryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            primaryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            primaryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            secondaryButton.centerYAnchor.constraint(equalTo: primaryButton.centerYAnchor),
            secondaryButton.leadingAnchor.constraint(equalTo: primaryButton.trailingAnchor, constant: 10),
            secondaryButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func configure(with model: RiseRitualCardModel) {
        titleLabel.text = model.title
        eyebrowLabel.text = model.eyebrowText
        messageLabel.text = model.message
        symbolImageView.image = UIImage(systemName: model.symbolName)
        primaryButton.configuration?.title = model.primaryActionTitle
        secondaryButton.configuration?.title = model.secondaryActionTitle
        transform = .identity
        alpha = 1
    }
    
    @objc private func closeTapped() {
        guard !isDismissing else { return }
        isDismissing = true
        
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            usingSpringWithDamping: 0.95,
            initialSpringVelocity: 0.2,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.96, y: 0.96).translatedBy(x: 0, y: -10)
            self?.alpha = 0
        } completion: { [weak self] _ in
            guard let self else { return }
            self.onDismissRequested?(self)
        }
    }
    
    @objc private func startTapped() {
        onStartTapped?()
    }
    
    @objc private func viewRiseTapped() {
        onViewRiseTapped?()
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !isDismissing else { return }
        
        let translation = gesture.translation(in: self)
        let progress = min(abs(translation.x) / max(bounds.width, 1), 1)
        
        switch gesture.state {
        case .changed:
            let compression = 1 - (progress * 0.04)
            transform = CGAffineTransform(translationX: translation.x, y: 0).scaledBy(x: 1, y: compression)
            alpha = 1 - (progress * 0.25)
            
        case .ended, .cancelled:
            let velocityX = gesture.velocity(in: self).x
            let shouldDismiss = abs(translation.x) > bounds.width * 0.35 || abs(velocityX) > 900
            
            if shouldDismiss {
                animateSwipeDismiss(velocityX: velocityX, translationX: translation.x)
            } else {
                UIView.animate(
                    withDuration: 0.45,
                    delay: 0,
                    usingSpringWithDamping: 0.78,
                    initialSpringVelocity: 0.4,
                    options: [.curveEaseOut, .allowUserInteraction]
                ) { [weak self] in
                    self?.transform = .identity
                    self?.alpha = 1
                }
            }
            
        default:
            break
        }
    }
    
    private func animateSwipeDismiss(velocityX: CGFloat, translationX: CGFloat) {
        guard !isDismissing else { return }
        isDismissing = true
        
        let direction: CGFloat = translationX == 0 ? (velocityX >= 0 ? 1 : -1) : (translationX >= 0 ? 1 : -1)
        let targetX = direction * (bounds.width + 48)
        
        UIView.animate(
            withDuration: 0.24,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction]
        ) { [weak self] in
            self?.transform = CGAffineTransform(translationX: targetX, y: 0).scaledBy(x: 0.98, y: 0.96)
            self?.alpha = 0
        } completion: { [weak self] _ in
            guard let self else { return }
            self.onDismissRequested?(self)
        }
    }
}
