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
            
            // Shadow
            glassContainer.layer.shadowColor = UIColor.black.cgColor
            glassContainer.layer.shadowOpacity = 0.08
            glassContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
            glassContainer.layer.shadowRadius = 12
            
            selectionStyle = .none
            backgroundColor = .clear
            
            titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        }

        private func setupChartAppearance() {
            barChartView.backgroundColor = .clear
            barChartView.rightAxis.enabled = false
            barChartView.chartDescription.enabled = false
            
            let xAxis = barChartView.xAxis
            xAxis.labelPosition = .bottom
            xAxis.drawGridLinesEnabled = false
            xAxis.granularity = 1
            xAxis.labelFont = .systemFont(ofSize: 10, weight: .medium)
            
            let leftAxis = barChartView.leftAxis
            leftAxis.drawGridLinesEnabled = true
            leftAxis.gridColor = .systemGray5
            leftAxis.axisMinimum = 0
            
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
            
            guard !dataSets.isEmpty else {
                barChartView.data = nil
                return
            }
            
            let colorPalette: [UIColor]
            switch dataSets.count {
            case 1:
                colorPalette = [.systemGreen]
            case 2:
                colorPalette = [.systemGreen, .systemBlue]
            case 3:
                colorPalette = [.systemGreen, .systemBlue, .systemOrange]
            default:
                let baseColors: [UIColor] = [.systemGreen, .systemBlue, .systemOrange, .systemPurple, .systemRed]
                colorPalette = Array(baseColors.prefix(dataSets.count))
            }
            
            // 1. Create chart data sets with fixed colors
            let chartDataSets: [BarChartDataSet] = dataSets.enumerated().map { index, model in
                let entries = model.values.map { BarChartDataEntry(x: $0.xIndex, y: $0.value) }
                let set = BarChartDataSet(entries: entries, label: model.label)
                set.setColor(colorPalette[index % colorPalette.count])
                set.drawValuesEnabled = false
                
                return set
            }
            
            // 2. Initialize BarChartData
            let chartData = BarChartData(dataSets: chartDataSets)
            
            // 3. Dynamic spacing calculation for uniformity
            let groupSpace = 0.3
            let barSpace = 0.05
            let barWidth = max(0.1, (1.0 - groupSpace) / Double(dataSets.count) - barSpace)
            chartData.barWidth = barWidth
            barChartView.data = chartData
            
            // 4. Configure X-axis min/max
            let startX = 0.0
            let endX = Double(xAxisLabels.count - 1)
            barChartView.xAxis.axisMaximum = endX 
            barChartView.xAxis.axisMinimum = startX
            
            // 5. Group bars only if multiple datasets exist
            if dataSets.count > 1 {
                let groupSpace = 0.3
                let barSpace = 0.05
                let barWidth = (1.0 - groupSpace) / Double(dataSets.count) - barSpace
                
                chartData.barWidth = barWidth
                chartData.groupBars(fromX: startX, groupSpace: groupSpace, barSpace: barSpace)
                
                barChartView.xAxis.centerAxisLabelsEnabled = true
            } else {
                chartData.barWidth = 0.5
                barChartView.xAxis.centerAxisLabelsEnabled = false
            }
            
            // 6. X-axis labels
            barChartView.xAxis.centerAxisLabelsEnabled = (dataSets.count > 1)
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
            barChartView.xAxis.labelCount = xAxisLabels.count
            barChartView.xAxis.granularity = 1
            
            // 7. Refresh and animate
            barChartView.notifyDataSetChanged()
            barChartView.animate(yAxisDuration: 1.0, easingOption: .easeOutCubic)
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            barChartView.data = nil
        }
    }
