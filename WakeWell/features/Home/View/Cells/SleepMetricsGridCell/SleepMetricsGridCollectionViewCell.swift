import UIKit

class SleepMetricsGridCollectionViewCell: UICollectionViewCell {

    // MARK: - Duration
    @IBOutlet weak var durationTitleLabel: UILabel!
    @IBOutlet weak var durationScoreLabel: UILabel!
    @IBOutlet weak var durationTrendLabel: UILabel!

    // MARK: - Efficiency
    @IBOutlet weak var efficiencyTitleLabel: UILabel!
    @IBOutlet weak var efficiencyScoreLabel: UILabel!
    @IBOutlet weak var efficiencyTrendLabel: UILabel!

    // MARK: - Architecture
    @IBOutlet weak var architectureTitleLabel: UILabel!
    @IBOutlet weak var architectureScoreLabel: UILabel!
    @IBOutlet weak var architectureTrendLabel: UILabel!

    // MARK: - Continuity
    @IBOutlet weak var continuityTitleLabel: UILabel!
    @IBOutlet weak var continuityScoreLabel: UILabel!
    @IBOutlet weak var continuityTrendLabel: UILabel!

    // MARK: - Calmness
    @IBOutlet weak var calmnessTitleLabel: UILabel!
    @IBOutlet weak var calmnessScoreLabel: UILabel!
    @IBOutlet weak var calmnessTrendLabel: UILabel!

    // MARK: - Consistency
    @IBOutlet weak var consistencyTitleLabel: UILabel!
    @IBOutlet weak var consistencyScoreLabel: UILabel!
    @IBOutlet weak var consistencyTrendLabel: UILabel!

    // MARK: - Views
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var efficiencyView: UIView!
    @IBOutlet weak var architectureView: UIView!
    @IBOutlet weak var continuityView: UIView!
    @IBOutlet weak var calmnessView: UIView!
    @IBOutlet weak var consistencyView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        applyStyling()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyShadowPath()
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 24
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .secondarySystemBackground

        layer.masksToBounds = false

        styleMetricView(durationView)
        styleMetricView(efficiencyView)
        styleMetricView(architectureView)
        styleMetricView(continuityView)
        styleMetricView(calmnessView)
        styleMetricView(consistencyView)
    }

    private func applyStyling() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    private func applyShadowPath() {
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 24
        ).cgPath
    }

    private func styleMetricView(_ view: UIView) {
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
    }

    // MARK: - Configure

    func configure(with viewModel: SleepMetricsViewModel) {

        let m = viewModel.metrics
        guard m.count >= 6 else { return }

        durationTitleLabel.text = m[0].title
        durationScoreLabel.text = m[0].valueText
        durationTrendLabel.text = m[0].trendText
        durationTrendLabel.textColor = m[0].trendColor

        efficiencyTitleLabel.text = m[1].title
        efficiencyScoreLabel.text = m[1].valueText
        efficiencyTrendLabel.text = m[1].trendText
        efficiencyTrendLabel.textColor = m[1].trendColor

        architectureTitleLabel.text = m[2].title
        architectureScoreLabel.text = m[2].valueText
        architectureTrendLabel.text = m[2].trendText
        architectureTrendLabel.textColor = m[2].trendColor

        continuityTitleLabel.text = m[3].title
        continuityScoreLabel.text = m[3].valueText
        continuityTrendLabel.text = m[3].trendText
        continuityTrendLabel.textColor = m[3].trendColor

        calmnessTitleLabel.text = m[4].title
        calmnessScoreLabel.text = m[4].valueText
        calmnessTrendLabel.text = m[4].trendText
        calmnessTrendLabel.textColor = m[4].trendColor

        consistencyTitleLabel.text = m[5].title
        consistencyScoreLabel.text = m[5].valueText
        consistencyTrendLabel.text = m[5].trendText
        consistencyTrendLabel.textColor = m[5].trendColor
    }
}
