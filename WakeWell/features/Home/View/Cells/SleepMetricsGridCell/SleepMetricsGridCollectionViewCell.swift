//
//  SleepMetricsGridCollectionViewCell.swift
//  WakeWell
//
//  Created by geu on 14/02/26.
//

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

        styleMetricView(durationView)
        styleMetricView(efficiencyView)
        styleMetricView(architectureView)
        styleMetricView(continuityView)
        styleMetricView(calmnessView)
        styleMetricView(consistencyView)
    }

    private func styleMetricView(_ view: UIView) {
        view.backgroundColor = UIColor.secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
    }
    
}
