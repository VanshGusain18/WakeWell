import UIKit

class SleepMetricsGridCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var durationTitleLabel:     UILabel!
    @IBOutlet weak var durationScoreLabel:     UILabel!
    @IBOutlet weak var durationTrendLabel:     UILabel!
    @IBOutlet weak var efficiencyTitleLabel:   UILabel!
    @IBOutlet weak var efficiencyScoreLabel:   UILabel!
    @IBOutlet weak var efficiencyTrendLabel:   UILabel!
    @IBOutlet weak var architectureTitleLabel: UILabel!
    @IBOutlet weak var architectureScoreLabel: UILabel!
    @IBOutlet weak var architectureTrendLabel: UILabel!
    @IBOutlet weak var continuityTitleLabel:   UILabel!
    @IBOutlet weak var continuityScoreLabel:   UILabel!
    @IBOutlet weak var continuityTrendLabel:   UILabel!
    @IBOutlet weak var calmnessTitleLabel:     UILabel!
    @IBOutlet weak var calmnessScoreLabel:     UILabel!
    @IBOutlet weak var calmnessTrendLabel:     UILabel!
    @IBOutlet weak var consistencyTitleLabel:  UILabel!
    @IBOutlet weak var consistencyScoreLabel:  UILabel!
    @IBOutlet weak var consistencyTrendLabel:  UILabel!
    @IBOutlet weak var durationView:           UIView!
    @IBOutlet weak var efficiencyView:         UIView!
    @IBOutlet weak var architectureView:       UIView!
    @IBOutlet weak var continuityView:         UIView!
    @IBOutlet weak var calmnessView:           UIView!
    @IBOutlet weak var consistencyView:        UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 24).cgPath
    }

    private func setupUI() {
        contentView.backgroundColor     = WakeWellTheme.cardBackground
        contentView.subviews.first?.backgroundColor = WakeWellTheme.cardBackground
        contentView.layer.cornerRadius  = 24
        contentView.layer.masksToBounds = true
        layer.masksToBounds  = false
        layer.shadowColor    = WakeWellTheme.shadowColor.cgColor
        layer.shadowOpacity  = WakeWellTheme.shadowOpacity
        layer.shadowRadius   = WakeWellTheme.shadowRadius
        layer.shadowOffset   = WakeWellTheme.shadowOffset

        [durationView, efficiencyView, architectureView,
         continuityView, calmnessView, consistencyView].forEach { styleMetricView($0) }
    }

    private func styleMetricView(_ view: UIView?) {
        guard let v = view else { return }
        v.backgroundColor        = WakeWellTheme.cardElevated
        v.layer.cornerRadius     = 12
        v.layer.masksToBounds    = true
        // Gold score labels
        for lbl in [v.subviews.compactMap { $0 as? UILabel }].flatMap({ $0 }) {
            if lbl.font.pointSize >= 18 { lbl.textColor = WakeWellTheme.accentGold }
            else                         { lbl.textColor = WakeWellTheme.labelSecondary }
        }
    }

    // ── Configure (logic unchanged) ────────────────────────────────────────
    func configure(with viewModel: SleepMetricsViewModel) {
        let m = viewModel.metrics
        guard m.count >= 6 else { return }

        durationTitleLabel.text     = m[0].title
        durationTitleLabel.textColor = WakeWellTheme.labelSecondary
        durationScoreLabel.text     = m[0].valueText
        durationScoreLabel.textColor = WakeWellTheme.accentGold
        durationTrendLabel.text     = m[0].trendText
        durationTrendLabel.textColor = m[0].trendColor

        efficiencyTitleLabel.text     = m[1].title
        efficiencyTitleLabel.textColor = WakeWellTheme.labelSecondary
        efficiencyScoreLabel.text     = m[1].valueText
        efficiencyScoreLabel.textColor = WakeWellTheme.accentGold
        efficiencyTrendLabel.text     = m[1].trendText
        efficiencyTrendLabel.textColor = m[1].trendColor

        architectureTitleLabel.text     = m[2].title
        architectureTitleLabel.textColor = WakeWellTheme.labelSecondary
        architectureScoreLabel.text     = m[2].valueText
        architectureScoreLabel.textColor = WakeWellTheme.accentGold
        architectureTrendLabel.text     = m[2].trendText
        architectureTrendLabel.textColor = m[2].trendColor

        continuityTitleLabel.text     = m[3].title
        continuityTitleLabel.textColor = WakeWellTheme.labelSecondary
        continuityScoreLabel.text     = m[3].valueText
        continuityScoreLabel.textColor = WakeWellTheme.accentGold
        continuityTrendLabel.text     = m[3].trendText
        continuityTrendLabel.textColor = m[3].trendColor

        calmnessTitleLabel.text     = m[4].title
        calmnessTitleLabel.textColor = WakeWellTheme.labelSecondary
        calmnessScoreLabel.text     = m[4].valueText
        calmnessScoreLabel.textColor = WakeWellTheme.accentGold
        calmnessTrendLabel.text     = m[4].trendText
        calmnessTrendLabel.textColor = m[4].trendColor

        consistencyTitleLabel.text     = m[5].title
        consistencyTitleLabel.textColor = WakeWellTheme.labelSecondary
        consistencyScoreLabel.text     = m[5].valueText
        consistencyScoreLabel.textColor = WakeWellTheme.accentGold
        consistencyTrendLabel.text     = m[5].trendText
        consistencyTrendLabel.textColor = m[5].trendColor
    }
}
