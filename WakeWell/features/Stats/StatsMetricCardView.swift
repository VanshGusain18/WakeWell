import UIKit

class StatsMetricCardView: UIView {

    // MARK: - UI

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    private var tapAction: (() -> Void)?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {

        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 18
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8

        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])

        // Tap
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }

    // MARK: - Configure

    func configure(title: String,value: String,onTap: (() -> Void)?) {

        titleLabel.text = title
        valueLabel.text = value
        tapAction = onTap
    }

    // MARK: - Action

    @objc private func handleTap() {
        tapAction?()
    }
}
