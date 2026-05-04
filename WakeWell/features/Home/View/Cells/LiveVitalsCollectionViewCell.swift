import UIKit

final class LiveVitalsCollectionViewCell: UICollectionViewCell {
    static let identifier = "LiveVitalsCollectionViewCell"

    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let lastUpdateLabel = UILabel()
    private let stackView = UIStackView()
    private let heartRateValueLabel = UILabel()
    private let hrvValueLabel = UILabel()
    private let motionValueLabel = UILabel()
    private let respiratoryRateValueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func configure() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refresh),
            name: .liveVitalsDidChange,
            object: nil
        )
        refresh()
    }

    @objc private func refresh() {
        let vitals = LiveVitalsViewModel.shared
        let connection = WatchConnectionMonitor.shared

        heartRateValueLabel.text = vitals.heartRate > 0 ? "\(Int(vitals.heartRate.rounded())) BPM" : "--"
        hrvValueLabel.text = vitals.hrv > 0 ? "\(String(format: "%.1f", vitals.hrv)) ms" : "--"
        motionValueLabel.text = vitals.motion > 0 ? String(format: "%.3f", vitals.motion) : "--"
        if let respiratoryRate = vitals.respiratoryRate {
            respiratoryRateValueLabel.text = "\(String(format: "%.1f", respiratoryRate)) /min"
        } else {
            respiratoryRateValueLabel.text = "--"
        }

        statusLabel.text = connection.state == .connected ? "Watch connected" : "Watch not connected"
        statusLabel.textColor = connection.state == .connected ? WakeWellTheme.accentPurple : WakeWellTheme.labelSecondary

        if let lastUpdated = vitals.lastUpdated {
            lastUpdateLabel.text = "Last update \(Self.timeFormatter.string(from: lastUpdated))"
        } else {
            lastUpdateLabel.text = "Last update --"
        }
    }

    private func setupUI() {
        contentView.backgroundColor = WakeWellTheme.cardBackground
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        layer.masksToBounds = false
        layer.shadowColor = WakeWellTheme.shadowColor.cgColor
        layer.shadowOpacity = WakeWellTheme.shadowOpacity
        layer.shadowRadius = WakeWellTheme.shadowRadius
        layer.shadowOffset = WakeWellTheme.shadowOffset

        titleLabel.text = "Live Vitals"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = WakeWellTheme.labelPrimary

        statusLabel.font = .systemFont(ofSize: 13, weight: .medium)
        lastUpdateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        lastUpdateLabel.textColor = WakeWellTheme.labelSecondary

        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let header = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        header.axis = .horizontal
        header.alignment = .firstBaseline
        header.distribution = .equalSpacing

        stackView.addArrangedSubview(header)
        stackView.addArrangedSubview(lastUpdateLabel)
        stackView.addArrangedSubview(metricGrid())

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -14)
        ])
    }

    private func metricGrid() -> UIStackView {
        let topRow = UIStackView(arrangedSubviews: [
            metricView(title: "Heart Rate", valueLabel: heartRateValueLabel),
            metricView(title: "HRV", valueLabel: hrvValueLabel)
        ])
        let bottomRow = UIStackView(arrangedSubviews: [
            metricView(title: "Motion", valueLabel: motionValueLabel),
            metricView(title: "Resp Rate", valueLabel: respiratoryRateValueLabel)
        ])

        [topRow, bottomRow].forEach {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.spacing = 8
        }

        let grid = UIStackView(arrangedSubviews: [topRow, bottomRow])
        grid.axis = .vertical
        grid.spacing = 8
        return grid
    }

    private func metricView(title: String, valueLabel: UILabel) -> UIView {
        let container = UIView()
        container.backgroundColor = WakeWellTheme.cardElevated
        container.layer.cornerRadius = 10
        container.layer.masksToBounds = true

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = WakeWellTheme.labelSecondary

        valueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        valueLabel.textColor = WakeWellTheme.accentGold
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.75

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 3
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            container.heightAnchor.constraint(equalToConstant: 58)
        ])

        return container
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()
}
