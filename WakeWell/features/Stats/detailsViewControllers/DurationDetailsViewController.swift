//
//  DurationDetailsViewController.swift
//  WakeWell
//
//  Created by geu on 14/02/26.
//
import UIKit
import DGCharts

class DurationDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var durationChartView: LineChartView!
    @IBOutlet weak var averageDurationLabel: UILabel!
    @IBOutlet weak var recommendedDurationLabel: UILabel!

    var sleepData: [SleepDurationData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Sleep Duration"
        descriptionLabel.text = "Your total sleep duration each night. Tracking this helps ensure you get enough rest."
        recommendedDurationLabel.text = "Recommended: 7–9 hours"

        sleepData = SleepDurationModel.getWeeklySleepDuration()

        styleChart(durationChartView)

        let average = calculateAverage()
        setupDurationChart(average: average)
    }
    
    func setupDurationChart(average: Double) {

        let entries = sleepData.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: $0.element.hoursSlept)
        }

        let dataSet = LineChartDataSet(entries: entries)

        dataSet.mode = .cubicBezier
        dataSet.lineWidth = 3
        dataSet.setColor(.systemBlue)
        dataSet.circleRadius = 5
        dataSet.setCircleColor(.systemBlue)
        dataSet.circleHoleColor = .systemBackground
        dataSet.circleHoleRadius = 2.5
        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = true

        let gradientColors = [UIColor.systemBlue.withAlphaComponent(0.3).cgColor,UIColor.clear.cgColor] as CFArray

        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),colors: gradientColors,locations: nil)!

        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)

        let safeEntries = sleepData.indices.map {
            ChartDataEntry(x: Double($0), y: 9)
        }

        let safeZone = LineChartDataSet(entries: safeEntries)
        safeZone.drawCirclesEnabled = false
        safeZone.drawValuesEnabled = false
        safeZone.lineWidth = 0
        safeZone.drawFilledEnabled = true
        safeZone.fillColor = UIColor.systemGreen.withAlphaComponent(0.55)
        safeZone.fillFormatter = DefaultFillFormatter { _, _ in return 7 }

        durationChartView.data = LineChartData(dataSets: [safeZone, dataSet])
        
        let days = sleepData.map { $0.day }
        durationChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        durationChartView.xAxis.granularity = 1
        durationChartView.xAxis.granularityEnabled = true
        durationChartView.xAxis.axisMinimum = 0
        durationChartView.xAxis.axisMaximum = Double(days.count - 1)

        let total = sleepData.reduce(0) { $0 + $1.hoursSlept }
        let average = total / Double(sleepData.count)

        let avgLine = ChartLimitLine(limit: average)
        avgLine.lineColor = .systemOrange
        avgLine.lineWidth = 2
        avgLine.lineDashLengths = [6, 4]
        avgLine.valueTextColor = .systemOrange

        durationChartView.leftAxis.removeAllLimitLines()
        durationChartView.leftAxis.addLimitLine(avgLine)
        durationChartView.layoutIfNeeded()
        durationChartView.animate(xAxisDuration: 0.0,yAxisDuration: 1.0,easingOption: .easeOutCubic)
    }

    private func styleChart(_ chart: LineChartView) {

        chart.chartDescription.enabled = false
        chart.legend.enabled = false
        chart.rightAxis.enabled = false

        chart.dragEnabled = false
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.setScaleEnabled(false)

        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = .secondaryLabel
        xAxis.granularity = 1

        let leftAxis = chart.leftAxis
        leftAxis.labelTextColor = .secondaryLabel
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 12
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = UIColor.systemGray5
        leftAxis.labelCount = 6
    }
    
    func calculateAverage() -> Double {

        let total = sleepData.reduce(0) { $0 + $1.hoursSlept }
        let average = total / Double(sleepData.count)
        averageDurationLabel.text = "Average: \(String(format: "%.1f", average)) hours"
        return average
    }
}
