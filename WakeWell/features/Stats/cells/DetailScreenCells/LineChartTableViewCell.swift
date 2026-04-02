//
//  LineCHartTableViewCell.swift
//  WakeWell
//
//  Created by geu on 23/03/26.
//

import UIKit
import DGCharts

class LineChartTableViewCell: UITableViewCell {
    
    @IBOutlet weak var glassContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    
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
        titleLabel.textColor = .label
    }
    
    private func setupChartAppearance() {
            lineChartView.backgroundColor = .clear
            lineChartView.rightAxis.enabled = false
            lineChartView.legend.enabled = false
            lineChartView.chartDescription.enabled = false
            
            // X-axis setup
            let xAxis = lineChartView.xAxis
            xAxis.labelPosition = .bottom
            xAxis.drawGridLinesEnabled = false
            xAxis.labelFont = .systemFont(ofSize: 10, weight: .medium)
            xAxis.granularity = 1
            xAxis.centerAxisLabelsEnabled = false 
            
            // Left axis setup
            let leftAxis = lineChartView.leftAxis
            leftAxis.drawGridLinesEnabled = true
            leftAxis.gridColor = .systemGray5
            leftAxis.labelFont = .systemFont(ofSize: 10)
            leftAxis.axisMinimum = 0
            
            lineChartView.animate(yAxisDuration: 1.0, easingOption: .easeOutCubic)
        }
    
    func configure(
        title: String,
        dataSets: [LineChartDataSetModel],
        xAxisLabels: [String]
    ) {
        titleLabel.text = title
        
        guard !dataSets.isEmpty else {
            lineChartView.data = nil
            return
        }
        
        let chartDataSets: [LineChartDataSet] = dataSets.map { model in
            let entries = model.values.map { ChartDataEntry(x: $0.xIndex, y: $0.value) }
            let set = LineChartDataSet(entries: entries, label: model.label)
            
            let fixedColor = UIColor.systemBlue
            set.setColor(fixedColor)
            set.lineWidth = 3
            set.mode = .cubicBezier
            set.drawValuesEnabled = false
            
            set.drawCirclesEnabled = true
            set.circleRadius = 4
            set.setCircleColor(fixedColor)
            
            // Gradient Fill
            let gradientColors = [fixedColor.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: nil)!
            set.fill = LinearGradientFill(gradient: gradient, angle: 90)
            set.drawFilledEnabled = true
            
            return set
        }
        
        let chartData = LineChartData(dataSets: chartDataSets)
        lineChartView.data = chartData
        
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
        lineChartView.xAxis.axisMinimum = 0
        lineChartView.xAxis.axisMaximum = Double(xAxisLabels.count - 1)
        
        lineChartView.notifyDataSetChanged()
        lineChartView.animate(yAxisDuration: 1.0, easingOption: .easeOutCubic)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        lineChartView.data = nil
    }
}
