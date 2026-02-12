import UIKit

class StatsMetricRowCell: UITableViewCell {

    private let leftCard = StatsMetricCardView()
    private let rightCard = StatsMetricCardView()

    override init(style: UITableViewCell.CellStyle,reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {

        selectionStyle = .none
        backgroundColor = .clear

        leftCard.translatesAutoresizingMaskIntoConstraints = false
        rightCard.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(leftCard)
        contentView.addSubview(rightCard)

        NSLayoutConstraint.activate([

            leftCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            leftCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            leftCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            leftCard.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -8),

            rightCard.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 8),
            rightCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            rightCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            rightCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Configure

    func configure(
        left: (title: String, value: String),
        right: (title: String, value: String),
        onLeftTap: (() -> Void)?,
        onRightTap: (() -> Void)?
    ) {

        leftCard.configure(
            title: left.title,
            value: left.value,
            onTap: onLeftTap
        )

        rightCard.configure(
            title: right.title,
            value: right.value,
            onTap: onRightTap
        )
    }
}
