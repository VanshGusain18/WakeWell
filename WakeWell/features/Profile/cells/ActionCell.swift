// ActionCell.swift
// SetSail

import UIKit

class ActionCell: UITableViewCell {

    static let reuseID = "ActionCell"

    // MARK: Private views

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
        actionButton.backgroundColor    = .clear
        actionButton.layer.cornerRadius = 14
        actionButton.layer.borderWidth  = 1.5
        actionButton.titleLabel?.font   = .systemFont(ofSize: 15, weight: .semibold)
        actionButton.clipsToBounds      = true
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        contentView.addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
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
