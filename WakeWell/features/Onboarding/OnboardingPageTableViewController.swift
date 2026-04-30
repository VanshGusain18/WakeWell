// OnboardingPageTableViewController.swift
// SetSail
//
// A single onboarding slide. No XIBs — fully code-driven.

import UIKit

// MARK: - Shared data model

struct OnboardingPage {
    let sfSymbol:    String
    let title:       String
    let subtitle:    String
    let accentColor: UIColor
}

// MARK: - View Controller

final class OnboardingPageTableViewController: UIViewController {

    // Set by the container before display
    var page: OnboardingPage?
    var pageIndex: Int = 0

    // MARK: Private views

    private let appBadgeView     = UIView()
    private let badgeIconView    = UIImageView()
    private let illustrationView = UIImageView()
    private let glowView         = UIView()
    private let titleLabel       = UILabel()
    private let subtitleLabel    = UILabel()   // kept for page subtitles (not the tagline)

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = WakeWellTheme.background
        buildLayout()
        applyContent()
    }

    // MARK: Layout

    private func buildLayout() {
        // ── App badge (top-centre) ──────────────────────────────────────────
        appBadgeView.backgroundColor    = .white
        appBadgeView.layer.cornerRadius = 22
        appBadgeView.layer.borderWidth  = 1.5
        appBadgeView.layer.borderColor  = WakeWellTheme.accentPurple.withAlphaComponent(0.25).cgColor
        appBadgeView.layer.shadowColor  = WakeWellTheme.accentPurple.cgColor
        appBadgeView.layer.shadowOpacity = 0.20
        appBadgeView.layer.shadowRadius = 12
        appBadgeView.layer.shadowOffset = CGSize(width: 0, height: 4)
        appBadgeView.translatesAutoresizingMaskIntoConstraints = false

        // Use SETSAIL logo asset; fall back to SF Symbol if asset missing
        if let logoImage = UIImage(named: "SetSailLogo") ?? UIImage(named: "AppIcon") {
            badgeIconView.image = logoImage
        } else {
            let badgeCfg = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
            badgeIconView.image = UIImage(systemName: "sailboat.fill", withConfiguration: badgeCfg)?
                                     .withTintColor(WakeWellTheme.accentPurple, renderingMode: .alwaysOriginal)
        }
        badgeIconView.contentMode = .scaleAspectFit
        badgeIconView.layer.cornerRadius = 14
        badgeIconView.clipsToBounds = true
        badgeIconView.translatesAutoresizingMaskIntoConstraints = false
        appBadgeView.addSubview(badgeIconView)

        // ── Glow halo behind illustration ───────────────────────────────────
        glowView.backgroundColor = .clear
        glowView.translatesAutoresizingMaskIntoConstraints = false

        // ── Illustration ────────────────────────────────────────────────────
        illustrationView.contentMode = .scaleAspectFit
        illustrationView.translatesAutoresizingMaskIntoConstraints = false

        // ── Title ────────────────────────────────────────────────────────────
        titleLabel.font          = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor     = WakeWellTheme.labelPrimary   // dark on light bg
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // ── Subtitle ─────────────────────────────────────────────────────────
        subtitleLabel.font          = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor     = WakeWellTheme.labelSecondary  // dark-secondary on light bg
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // ── Add to hierarchy ──────────────────────────────────────────────────
        view.addSubview(appBadgeView)
        view.addSubview(glowView)
        view.addSubview(illustrationView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            // Badge — centred, 40 pts from top
            appBadgeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            appBadgeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appBadgeView.widthAnchor.constraint(equalToConstant: 64),
            appBadgeView.heightAnchor.constraint(equalToConstant: 64),

            // Icon inside badge
            badgeIconView.centerXAnchor.constraint(equalTo: appBadgeView.centerXAnchor),
            badgeIconView.centerYAnchor.constraint(equalTo: appBadgeView.centerYAnchor),
            badgeIconView.widthAnchor.constraint(equalToConstant: 32),
            badgeIconView.heightAnchor.constraint(equalToConstant: 32),

            // Glow — same centre as illustration
            glowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glowView.topAnchor.constraint(equalTo: appBadgeView.bottomAnchor, constant: 20),
            glowView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            glowView.heightAnchor.constraint(equalTo: glowView.widthAnchor),

            // Illustration — inside the glow layer
            illustrationView.centerXAnchor.constraint(equalTo: glowView.centerXAnchor),
            illustrationView.centerYAnchor.constraint(equalTo: glowView.centerYAnchor),
            illustrationView.widthAnchor.constraint(equalTo: glowView.widthAnchor, multiplier: 0.85),
            illustrationView.heightAnchor.constraint(equalTo: glowView.heightAnchor, multiplier: 0.85),

            // Title — 28 pts below glow
            titleLabel.topAnchor.constraint(equalTo: glowView.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            // Subtitle — 12 pts below title
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16)
        ])
    }

    private func applyContent() {
        guard let page = page else { return }

        // Illustration
        let cfg = UIImage.SymbolConfiguration(pointSize: 100, weight: .thin)
        illustrationView.image = UIImage(systemName: page.sfSymbol, withConfiguration: cfg)?
                                   .withTintColor(page.accentColor, renderingMode: .alwaysOriginal)

        // Glow circle matching accent
        drawGlow(color: page.accentColor)

        // Badge border accent — subtle on light bg
        appBadgeView.layer.borderColor = page.accentColor.withAlphaComponent(0.30).cgColor
        appBadgeView.layer.shadowColor = page.accentColor.cgColor

        // Badge icon: keep SETSAIL logo if asset available; otherwise use page symbol
        if UIImage(named: "SetSailLogo") == nil && UIImage(named: "AppIcon") == nil {
            let badgeCfg = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
            badgeIconView.image = UIImage(systemName: page.sfSymbol, withConfiguration: badgeCfg)?
                                   .withTintColor(page.accentColor, renderingMode: .alwaysOriginal)
        }

        titleLabel.text    = page.title
        subtitleLabel.text = page.subtitle
    }

    private func drawGlow(color: UIColor) {
        // Draw a radial gradient glow as a sublayer
        glowView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let size = CGSize(width: 240, height: 240)
        let grad = CAGradientLayer()
        grad.type       = .radial
        grad.colors     = [
            color.withAlphaComponent(0.22).cgColor,
            color.withAlphaComponent(0.07).cgColor,
            UIColor.clear.cgColor
        ]
        grad.locations  = [0.0, 0.5, 1.0]
        grad.startPoint = CGPoint(x: 0.5, y: 0.5)
        grad.endPoint   = CGPoint(x: 1.0, y: 1.0)
        grad.frame      = CGRect(origin: .zero, size: size)
        glowView.layer.insertSublayer(grad, at: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Refresh glow frame after layout
        if let grad = glowView.layer.sublayers?.first as? CAGradientLayer {
            grad.frame = glowView.bounds
        }
    }
}
