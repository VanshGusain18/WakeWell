//
//  ActivityStepListCell.swift
//  WakeWell
//

import UIKit

final class ActivityStepListCell: UITableViewCell {

    static let identifier = "ActivityStepListCell"

    // MARK: - Subviews (programmatic — no XIB)
    private let cardView     = UIView()
    private let sectionLabel = UILabel()
    private let stackView    = UIStackView()

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

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10

        contentView.addSubview(cardView)
        cardView.addSubview(sectionLabel)
        cardView.addSubview(stackView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            sectionLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            sectionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            sectionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            stackView.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),
        ])
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    // MARK: - Configure

    func configure(sectionTitle: String, steps: [String]) {
        sectionLabel.text = sectionTitle

        for (index, step) in steps.enumerated() {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 17)
            label.textColor = WakeWellTheme.labelSecondary
            label.text = "\(index + 1). \(step)"
            stackView.addArrangedSubview(label)
        }
    }
}
