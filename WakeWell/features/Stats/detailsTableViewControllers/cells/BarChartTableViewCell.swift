//
//  BarChartTableViewCell.swift
//  WakeWell
//
//  Created by geu on 23/03/26.
//

import UIKit
import DGCharts

class BarChartTableViewCell: UITableViewCell {
    
    @IBOutlet weak var glassContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupStyle()
        setupChartAppearance()
    }
    private func setupStyle() {
            // Liquid Glass Container
            glassContainer.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            glassContainer.layer.cornerRadius = 24
            glassContainer.layer.borderWidth = 1.0
            glassContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            
            // Shadow for depth
            glassContainer.layer.shadowColor = UIColor.black.cgColor
            glassContainer.layer.shadowOpacity = 0.08
            glassContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
            glassContainer.layer.shadowRadius = 12
            
            selectionStyle = .none
            backgroundColor = .clear
            
            titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            titleLabel.text = "Sleep vs. Time in Bed"
        }
    private func setupChartAppearance() {
            barChartView.backgroundColor = .clear
            barChartView.rightAxis.enabled = false
            barChartView.chartDescription.enabled = false
            
            let xAxis = barChartView.xAxis
            xAxis.labelPosition = .bottom
            xAxis.drawGridLinesEnabled = false
            xAxis.granularity = 1
            xAxis.centerAxisLabelsEnabled = true
            xAxis.labelFont = .systemFont(ofSize: 10, weight: .medium)
            
            let leftAxis = barChartView.leftAxis
            leftAxis.drawGridLinesEnabled = true
            leftAxis.gridColor = .systemGray5
            leftAxis.axisMinimum = 0
            
            // Legend styling within the glass
            let legend = barChartView.legend
            legend.horizontalAlignment = .center
            legend.verticalAlignment = .bottom
            legend.orientation = .horizontal
            legend.drawInside = false
            legend.font = .systemFont(ofSize: 11)
        }
    func configure(
            title: String,
            dataSets: [BarChartDataSetModel],
            xAxisLabels: [String]
        ) {
            titleLabel.text = title
            
            let chartDataSets: [BarChartDataSet] = dataSets.map { model in
                
                let entries = model.values.map {
                    BarChartDataEntry(x: $0.xIndex, y: $0.value)
                }
                
                let set = BarChartDataSet(entries: entries, label: model.label)
                set.setColor(model.color)
                set.drawValuesEnabled = false
                
                return set
            }
            
            let chartData = BarChartData(dataSets: chartDataSets)
            
            // Dynamic grouping (important for reuse)
            let groupSpace = 0.3
            let barSpace = 0.05
            let barWidth = (1.0 - groupSpace) / Double(dataSets.count) - barSpace
            
            chartData.barWidth = barWidth
            barChartView.data = chartData
            
            barChartView.xAxis.axisMinimum = 0
            barChartView.xAxis.axisMaximum = Double(xAxisLabels.count)
            
            if dataSets.count > 1 {
                chartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
            }
            
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
            
            barChartView.animate(yAxisDuration: 1.0, easingOption: .easeOutCubic)
        }
    override func prepareForReuse() {
            super.prepareForReuse()
            barChartView.data = nil
        }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
