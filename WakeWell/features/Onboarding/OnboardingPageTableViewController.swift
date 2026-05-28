// OnboardingPageTableViewController.swift
// SetSail
//
// A single onboarding slide. No XIBs - fully code-driven.

import UIKit

// MARK: - Shared data model

struct OnboardingPage {
    struct Hero {
        enum Kind {
            case logo
            case symbol(String)
        }

        let kind: Kind
        let accentColor: UIColor
    }

    let eyebrow: String
    let title: String
    let subtitle: String
    let accentColor: UIColor
    let hero: Hero
    let highlights: [String]
}

// MARK: - View Controller

final class OnboardingPageTableViewController: UIViewController {

    // Set by the container before display
    var page: OnboardingPage?
    var pageIndex: Int = 0

    // MARK: Private views

    private let backgroundGradient = CAGradientLayer()

    private let contentStack = UIStackView()

    private let heroCard = UIView()
    private let heroCardGradient = CAGradientLayer()
    private let heroBubble = UIView()
    private let heroImageView = UIImageView()

    private let eyebrowLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let highlightsStack = UIStackView()

    private var didAnimateIn = false

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        buildLayout()
        applyContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateInIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
        heroCardGradient.frame = heroCard.bounds
        heroCard.layer.shadowPath = UIBezierPath(
            roundedRect: heroCard.bounds,
            cornerRadius: 32
        ).cgPath
        heroBubble.layer.cornerRadius = heroBubble.bounds.width / 2
    }

    // MARK: Layout

    private func buildLayout() {
        installBackgroundGradient()
        configureContentStack()
        configureHeroCard()
        configureLabels()
        configureHighlightsStack()

        view.addSubview(contentStack)
        contentStack.addArrangedSubview(heroCard)
        contentStack.addArrangedSubview(eyebrowLabel)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(highlightsStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 72),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            heroCard.heightAnchor.constraint(equalToConstant: 282),
            highlightsStack.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func installBackgroundGradient() {
        backgroundGradient.colors = [
            UIColor(hex: "#F8F7FF").cgColor,
            UIColor(hex: "#F1EEFF").cgColor,
            UIColor(hex: "#E7E2FF").cgColor
        ]
        backgroundGradient.locations = [0.0, 0.45, 1.0]
        backgroundGradient.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0.5, y: 1)
        backgroundGradient.frame = view.bounds
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func configureContentStack() {
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
    }

    private func configureHeroCard() {
        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroCard.backgroundColor = WakeWellTheme.cardBackground
        heroCard.layer.cornerRadius = 32
        heroCard.layer.borderWidth = 1
        heroCard.layer.borderColor = WakeWellTheme.border.cgColor
        heroCard.layer.shadowColor = WakeWellTheme.shadowColor.cgColor
        heroCard.layer.shadowOpacity = 0.16
        heroCard.layer.shadowRadius = 24
        heroCard.layer.shadowOffset = CGSize(width: 0, height: 14)
        heroCard.clipsToBounds = false

        heroCardGradient.colors = [
            WakeWellTheme.accentPurple.withAlphaComponent(0.16).cgColor,
            WakeWellTheme.cardBackground.withAlphaComponent(0.90).cgColor,
            WakeWellTheme.cardBackground.cgColor
        ]
        heroCardGradient.locations = [0.0, 0.55, 1.0]
        heroCardGradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        heroCardGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        heroCard.layer.insertSublayer(heroCardGradient, at: 0)

        heroBubble.translatesAutoresizingMaskIntoConstraints = false
        heroBubble.backgroundColor = WakeWellTheme.purpleTint
        heroBubble.layer.masksToBounds = false

        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.contentMode = .scaleAspectFit
        heroImageView.tintColor = WakeWellTheme.accentPurple

        heroCard.addSubview(heroBubble)
        heroCard.addSubview(heroImageView)

        NSLayoutConstraint.activate([
            heroBubble.centerXAnchor.constraint(equalTo: heroCard.centerXAnchor),
            heroBubble.centerYAnchor.constraint(equalTo: heroCard.centerYAnchor, constant: -8),
            heroBubble.widthAnchor.constraint(equalTo: heroCard.widthAnchor, multiplier: 0.56),
            heroBubble.heightAnchor.constraint(equalTo: heroBubble.widthAnchor),

            heroImageView.centerXAnchor.constraint(equalTo: heroBubble.centerXAnchor),
            heroImageView.centerYAnchor.constraint(equalTo: heroBubble.centerYAnchor),
            heroImageView.widthAnchor.constraint(lessThanOrEqualTo: heroBubble.widthAnchor, multiplier: 0.66),
            heroImageView.heightAnchor.constraint(equalTo: heroImageView.widthAnchor)
        ])
    }

    private func configureLabels() {
        eyebrowLabel.translatesAutoresizingMaskIntoConstraints = false
        eyebrowLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        eyebrowLabel.textColor = WakeWellTheme.accentGold
        eyebrowLabel.numberOfLines = 1
        eyebrowLabel.adjustsFontSizeToFitWidth = true
        eyebrowLabel.minimumScaleFactor = 0.85
        eyebrowLabel.textAlignment = .left
        eyebrowLabel.alpha = 0
        eyebrowLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        eyebrowLabel.setContentHuggingPriority(.required, for: .vertical)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 31, weight: .bold)
        titleLabel.textColor = WakeWellTheme.labelPrimary
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.alpha = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = WakeWellTheme.labelSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .left
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.alpha = 0
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func configureHighlightsStack() {
        highlightsStack.axis = .horizontal
        highlightsStack.spacing = 10
        highlightsStack.alignment = .fill
        highlightsStack.distribution = .fillEqually
        highlightsStack.translatesAutoresizingMaskIntoConstraints = false
        highlightsStack.alpha = 0
    }

    private func setHighlightPills(_ texts: [String], accentColor: UIColor) {
        highlightsStack.arrangedSubviews.forEach { subview in
            highlightsStack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        let targetTexts = texts.isEmpty ? ["Sleep science", "Calmer mornings"] : texts
        for text in targetTexts.prefix(2) {
            let pill = makeHighlightPill(text: text, accentColor: accentColor)
            highlightsStack.addArrangedSubview(pill)
        }
    }

    private func makeHighlightPill(text: String, accentColor: UIColor) -> UIView {
        let pill = UIView()
        pill.backgroundColor = accentColor.withAlphaComponent(0.12)
        pill.layer.cornerRadius = 18
        pill.layer.borderWidth = 1
        pill.layer.borderColor = accentColor.withAlphaComponent(0.18).cgColor

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = accentColor
        label.textAlignment = .center
        label.numberOfLines = 1

        pill.addSubview(label)
        NSLayoutConstraint.activate([
            pill.heightAnchor.constraint(equalToConstant: 40),
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -12),
            label.centerYAnchor.constraint(equalTo: pill.centerYAnchor)
        ])

        return pill
    }

    private func applyContent() {
        guard let page = page else { return }

        eyebrowLabel.text = page.eyebrow.uppercased()
        titleLabel.text = page.title
        subtitleLabel.text = page.subtitle

        heroBubble.backgroundColor = page.accentColor.withAlphaComponent(0.16)
        heroCardGradient.colors = [
            page.accentColor.withAlphaComponent(0.16).cgColor,
            WakeWellTheme.cardBackground.withAlphaComponent(0.92).cgColor,
            WakeWellTheme.cardBackground.cgColor
        ]
        eyebrowLabel.textColor = page.accentColor

        switch page.hero.kind {
        case .logo:
            let logoImage = UIImage(named: "SetSailLogo") ?? UIImage(named: "AppIcon")
            heroImageView.image = logoImage
            heroImageView.contentMode = .scaleAspectFit

        case .symbol(let symbol):
            let cfg = UIImage.SymbolConfiguration(pointSize: 102, weight: .thin)
            heroImageView.image = UIImage(systemName: symbol, withConfiguration: cfg)?
                .withTintColor(page.hero.accentColor, renderingMode: .alwaysOriginal)
            heroImageView.contentMode = .scaleAspectFit
            heroImageView.tintColor = page.hero.accentColor
        }

        setHighlightPills(page.highlights, accentColor: page.hero.accentColor)
    }

    private func animateInIfNeeded() {
        guard !didAnimateIn else { return }
        didAnimateIn = true

        let views: [UIView] = [
            heroCard,
            eyebrowLabel,
            titleLabel,
            subtitleLabel,
            highlightsStack
        ]

        for view in views {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 12)
        }

        for (index, view) in views.enumerated() {
            UIView.animate(
                withDuration: 0.65,
                delay: 0.06 * Double(index),
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.2,
                options: [.curveEaseOut],
                animations: {
                    view.alpha = 1
                    view.transform = .identity
                }
            )
        }
    }
}
