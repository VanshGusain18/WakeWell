//
//  StatsMetricRowCell.swift
//  WakeWell
//
//  Created by geu on 10/02/26.
//
import UIKit

class StatsMetricRowCell: UITableViewCell {

    private let leftCard = StatsMetricCardView()
    private let rightCard = StatsMetricCardView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.addSubview(leftCard)
        contentView.addSubview(rightCard)

        leftCard.translatesAutoresizingMaskIntoConstraints = false
        rightCard.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leftCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            leftCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            leftCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            rightCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightCard.topAnchor.constraint(equalTo: leftCard.topAnchor),
            rightCard.bottomAnchor.constraint(equalTo: leftCard.bottomAnchor),

            leftCard.trailingAnchor.constraint(equalTo: rightCard.leadingAnchor, constant: -16),
            leftCard.widthAnchor.constraint(equalTo: rightCard.widthAnchor)
        ])
    }

    func configure(left: (String, String), right: (String, String)) {
        leftCard.configure(title: left.0, value: left.1)
        rightCard.configure(title: right.0, value: right.1)
    }
}
