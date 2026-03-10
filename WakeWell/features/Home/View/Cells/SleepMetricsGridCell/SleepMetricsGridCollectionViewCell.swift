import UIKit

class SleepMetricsGridCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var durationTitleLabel: UILabel!
    @IBOutlet weak var durationScoreLabel: UILabel!
    @IBOutlet weak var durationTrendLabel: UILabel!
    
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
}
