// ActionCell.swift
// SetSail

import UIKit

class ActionCell: UITableViewCell {

    static let reuseID = "ActionCell"

    // MARK: Private views

    private let cardView     = UIView()
    private let actionButton = UIButton(type: .system)

    // MARK: Callback

    var onTap: (() -> Void)?

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
        // Card container — floats with horizontal spacing handled by willDisplay inset
        cardView.backgroundColor    = WakeWellTheme.cardBackground
        cardView.layer.cornerRadius = 18
        cardView.layer.shadowColor  = WakeWellTheme.shadowColor.cgColor
        cardView.layer.shadowOpacity = WakeWellTheme.shadowOpacity
        cardView.layer.shadowRadius  = WakeWellTheme.shadowRadius
        cardView.layer.shadowOffset  = WakeWellTheme.shadowOffset
        cardView.layer.masksToBounds = false
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // Button
        actionButton.backgroundColor    = .clear
        actionButton.layer.cornerRadius = 14
        actionButton.layer.borderWidth  = 1.5
        actionButton.titleLabel?.font   = .systemFont(ofSize: 15, weight: .semibold)
        actionButton.clipsToBounds      = true
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        cardView.addSubview(actionButton)
        contentView.addSubview(cardView)

        NSLayoutConstraint.activate([
            // Card fills contentView (horizontal inset applied via willDisplay)
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            // Button inside card with inner padding
            actionButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    // MARK: Configure

    func configure(title: String, isDestructive: Bool) {
        actionButton.setTitle(title, for: .normal)
        if isDestructive {
            let red = UIColor(hex: "#FF6B6B")
            actionButton.setTitleColor(red, for: .normal)
            actionButton.layer.borderColor = red.withAlphaComponent(0.6).cgColor
        } else {
            actionButton.setTitleColor(WakeWellTheme.accentPurple, for: .normal)
            actionButton.layer.borderColor = WakeWellTheme.accentPurple.withAlphaComponent(0.6).cgColor
        }
    }

    @objc private func buttonTapped() { onTap?() }
}
