//
//  StatsMetricCardView.swift
//  WakeWell
//
//  Created by geu on 11/02/26.
//
import UIKit

class StatsMetricCardView: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor

        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel

        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = .label

        addSubview(titleLabel)
        addSubview(valueLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            valueLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}
