//
//  ActivityTextBlockCell.swift
//  WakeWell
//

import UIKit

final class ActivityTextBlockCell: UITableViewCell {

    static let identifier = "ActivityTextBlockCell"

    // MARK: - Subviews (programmatic — no XIB)
    private let cardView     = UIView()
    private let sectionLabel = UILabel()
    private let bodyLabel    = UILabel()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    // MARK: - Setup

    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 20
        cardView.backgroundColor = WakeWellTheme.cardElevated

        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        sectionLabel.textColor = WakeWellTheme.labelSecondary

        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = .systemFont(ofSize: 16)
        bodyLabel.textColor = WakeWellTheme.labelPrimary
        bodyLabel.numberOfLines = 0

        contentView.addSubview(cardView)
        cardView.addSubview(sectionLabel)
        cardView.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            sectionLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            sectionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            sectionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            bodyLabel.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            bodyLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            bodyLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),
        ])
    }

    // MARK: - Configure

    func configure(sectionTitle: String, body: String) {
        sectionLabel.text = sectionTitle
        bodyLabel.text = body
    }
}
