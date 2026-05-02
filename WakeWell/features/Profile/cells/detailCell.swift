// detailCell.swift
// SetSail

import UIKit

class DetailCell: UITableViewCell {

    static let reuseID = "DetailCell"

    // MARK: Private views

    private let iconContainer = UIView()
    private let iconView      = UIImageView()
    private let titleLabel    = UILabel()
    private let valueLabel    = UILabel()

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

        // ── Icon container pill ───────────────────────────────────────────
        iconContainer.backgroundColor    = WakeWellTheme.purpleTint
        iconContainer.layer.cornerRadius = 10
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor   = WakeWellTheme.accentPurple
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)

        // ── Title ─────────────────────────────────────────────────────────
        titleLabel.font      = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = WakeWellTheme.labelSecondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // ── Value ─────────────────────────────────────────────────────────
        valueLabel.font          = .systemFont(ofSize: 15, weight: .semibold)
        valueLabel.textColor     = WakeWellTheme.labelPrimary
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(iconContainer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            // Icon container — 16 pt from card edge
            iconContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 34),
            iconContainer.heightAnchor.constraint(equalToConstant: 34),

            // Icon inside container
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 17),
            iconView.heightAnchor.constraint(equalToConstant: 17),

            // Title — next to icon
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            // Value — pinned 16 pt from right edge
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
    }

    // MARK: Configure

    func configure(title: String, value: String, sfSymbol: String = "info.circle") {
        titleLabel.text = title
        valueLabel.text = value

        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iconView.image = UIImage(systemName: sfSymbol, withConfiguration: cfg)
    }
}
