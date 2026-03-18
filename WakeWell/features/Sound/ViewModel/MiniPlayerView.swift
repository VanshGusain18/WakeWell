import UIKit

class MiniPlayerView: UIView {

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

    // UI
    let artworkImageView = UIImageView()
    let titleLabel = UILabel()

    let playPauseButton = UIButton(type: .system)
    let nextButton = UIButton(type: .system)
    let previousButton = UIButton(type: .system)

    let containerButton = UIButton()
    var onContainerTap: (() -> Void)?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear

        layer.cornerRadius = 20
        layer.masksToBounds = false

        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)

        // Blur
        blurView.layer.cornerRadius = 20
        blurView.clipsToBounds = true
        addSubview(blurView)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

     //Image
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        artworkImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        artworkImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        artworkImageView.layer.cornerRadius = 8
        artworkImageView.clipsToBounds = true
        artworkImageView.contentMode = .scaleAspectFill
        artworkImageView.backgroundColor = .systemGray5

        //Title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

       //Buttons
        [playPauseButton, nextButton, previousButton].forEach {
            $0.tintColor = .label
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: 32).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 32).isActive = true
        }

        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        nextButton.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        previousButton.setImage(UIImage(systemName: "backward.fill"), for: .normal)

        let buttonStack = UIStackView(arrangedSubviews: [
            previousButton,
            playPauseButton,
            nextButton
        ])

        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.spacing = 12


        buttonStack.setContentHuggingPriority(.required, for: .horizontal)
        buttonStack.setContentCompressionResistancePriority(.required, for: .horizontal)

       //Main Stack
        let mainStack = UIStackView(arrangedSubviews: [
            artworkImageView,
            titleLabel,
            buttonStack
        ])

        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 12
        mainStack.distribution = .fill

        blurView.contentView.addSubview(mainStack)

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor)
        ])

        // Tap Layer
        addSubview(containerButton)
        containerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerButton.topAnchor.constraint(equalTo: topAnchor),
            containerButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        containerButton.addTarget(self, action: #selector(containerTapped), for: .touchUpInside)
    }

   // Actions
    @objc private func containerTapped() {
        onContainerTap?()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        if playPauseButton.frame.contains(convert(point, to: playPauseButton.superview)) {
            return playPauseButton
        }
        if nextButton.frame.contains(convert(point, to: nextButton.superview)) {
            return nextButton
        }
        if previousButton.frame.contains(convert(point, to: previousButton.superview)) {
            return previousButton
        }

        return super.hitTest(point, with: event)
    }

        //Update
    func updateUI(title: String, image: UIImage?, isPlaying: Bool) {
        titleLabel.text = title
        artworkImageView.image = image

        let icon = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: icon), for: .normal)
    }
}
