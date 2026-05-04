// avatarcell.swift
// SetSail

import UIKit

class AvatarCell: UITableViewCell {

    static let reuseID = "AvatarCell"

    // MARK: Private views

    private let avatarCircle    = UIView()
    private let initialsLabel   = UILabel()
    private let nameLabel       = UILabel()
    private let emailLabel      = UILabel()
    private let memberSinceLabel = UILabel()

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle              = .none
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        buildUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    // MARK: Layout

    private func buildUI() {

        // ── Avatar circle ─────────────────────────────────────────────────
        avatarCircle.backgroundColor    = WakeWellTheme.accentPurple
        avatarCircle.layer.cornerRadius = 44
        avatarCircle.clipsToBounds      = true
        // outer glow (needs masksToBounds = false on a wrapper, or just use shadow on a wrapper)
        avatarCircle.translatesAutoresizingMaskIntoConstraints = false

        // Glow wrapper so shadow doesn't clip
        let glowWrapper = UIView()
        glowWrapper.backgroundColor    = .clear
        glowWrapper.layer.cornerRadius = 44
        glowWrapper.layer.shadowColor  = WakeWellTheme.accentPurple.withAlphaComponent(0.5).cgColor
        glowWrapper.layer.shadowOpacity = 0.55
        glowWrapper.layer.shadowRadius = 14
        glowWrapper.layer.shadowOffset = CGSize(width: 0, height: 4)
        glowWrapper.translatesAutoresizingMaskIntoConstraints = false
        glowWrapper.addSubview(avatarCircle)

        NSLayoutConstraint.activate([
            avatarCircle.topAnchor.constraint(equalTo: glowWrapper.topAnchor),
            avatarCircle.bottomAnchor.constraint(equalTo: glowWrapper.bottomAnchor),
            avatarCircle.leadingAnchor.constraint(equalTo: glowWrapper.leadingAnchor),
            avatarCircle.trailingAnchor.constraint(equalTo: glowWrapper.trailingAnchor)
        ])

        // Gold border ring on the circle
        avatarCircle.layer.borderWidth = 2.5
        avatarCircle.layer.borderColor = WakeWellTheme.accentGold.cgColor

        // ── Initials ──────────────────────────────────────────────────────
        initialsLabel.font          = .systemFont(ofSize: 30, weight: .bold)
        initialsLabel.textColor     = .white
        initialsLabel.textAlignment = .center
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarCircle.addSubview(initialsLabel)

        // ── Text labels ───────────────────────────────────────────────────
        nameLabel.font          = .systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor     = WakeWellTheme.labelPrimary
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        emailLabel.font          = .systemFont(ofSize: 14, weight: .regular)
        emailLabel.textColor     = WakeWellTheme.labelSecondary
        emailLabel.numberOfLines = 1
        emailLabel.translatesAutoresizingMaskIntoConstraints = false

        memberSinceLabel.font          = .systemFont(ofSize: 12, weight: .regular)
        memberSinceLabel.textColor     = WakeWellTheme.labelTertiary
        memberSinceLabel.numberOfLines = 1
        memberSinceLabel.translatesAutoresizingMaskIntoConstraints = false

        // ── Text stack ────────────────────────────────────────────────────
        let textStack = UIStackView(arrangedSubviews: [nameLabel, emailLabel, memberSinceLabel])
        textStack.axis      = .vertical
        textStack.spacing   = 3
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false

        // ── Horizontal stack: avatar + text ───────────────────────────────
        let hStack = UIStackView(arrangedSubviews: [glowWrapper, textStack])
        hStack.axis      = .horizontal
        hStack.spacing   = 18
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(hStack)

        NSLayoutConstraint.activate([
            // Initials inside avatar
            initialsLabel.centerXAnchor.constraint(equalTo: avatarCircle.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarCircle.centerYAnchor),

            // Avatar size
            glowWrapper.widthAnchor.constraint(equalToConstant: 88),
            glowWrapper.heightAnchor.constraint(equalToConstant: 88),

            // hStack pinned to contentView — use 16 pt inner padding (card already has 20 pt outer inset)
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: Configure

    func configure(initials: String, name: String, email: String, memberSince: String) {
        initialsLabel.text    = initials.isEmpty ? "?" : initials.uppercased()
        nameLabel.text        = name
        emailLabel.text       = email
        memberSinceLabel.text = memberSince.isEmpty ? "" : "Member since \(memberSince)"
    }
}
