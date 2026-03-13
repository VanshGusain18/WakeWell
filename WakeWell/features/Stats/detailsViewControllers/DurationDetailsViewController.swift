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
        title = "Duration"
        titleLabel.text = "Sleep Duration"
        descriptionLabel.text = "Your total sleep duration each night. Tracking this helps ensure you get enough rest."
        recommendedDurationLabel.text = "Recommended: 7–9 hours"
        sleepData = SleepDurationModel.getWeeklySleepDuration()
        
        let average = calculateAverage()

        setupDurationChart(average: average)
    }
    func setupDurationChart(average: Double) {

        var entries: [ChartDataEntry] = []

        for (index, data) in sleepData.enumerated() {
            entries.append(
                ChartDataEntry(x: Double(index), y: data.hoursSlept)
            )
        }

        let dataSet = LineChartDataSet(entries: entries)
        dataSet.colors = [.systemIndigo]
        dataSet.circleColors = [.systemIndigo]
        dataSet.lineWidth = 2
        dataSet.mode = .cubicBezier
        dataSet.drawValuesEnabled = false

        //SAFE ZONE DATASET (7–9 hours)
        
        var safeEntries: [ChartDataEntry] = []
        
        for i in 0..<sleepData.count {
            safeEntries.append(
                ChartDataEntry(x: Double(i), y: 9)
            )
        }

        let safeZone = LineChartDataSet(entries: safeEntries)
        safeZone.drawCirclesEnabled = false
        safeZone.drawValuesEnabled = false
        safeZone.lineWidth = 0
        safeZone.drawFilledEnabled = true
        safeZone.fillColor = UIColor.systemBlue.withAlphaComponent(0.15)
        safeZone.fillFormatter = DefaultFillFormatter { _,_ in return 7 }

        let chartData = LineChartData(dataSets: [safeZone, dataSet])
        durationChartView.data = chartData

        // AXIS SETTINGS
        
        durationChartView.rightAxis.enabled = false
        durationChartView.chartDescription.enabled = false

        durationChartView.leftAxis.axisMinimum = 0
        durationChartView.leftAxis.axisMaximum = 12
        durationChartView.leftAxis.gridColor = UIColor.systemGray5

        durationChartView.xAxis.labelPosition = .bottom
        durationChartView.xAxis.drawGridLinesEnabled = false
        
        let days = sleepData.map { $0.day }
        durationChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        durationChartView.xAxis.granularity = 1
        durationChartView.legend.enabled = false

        // AVERAGE LINE

        let total = sleepData.reduce(0) { $0 + $1.hoursSlept }
        let average = total / Double(sleepData.count)

        let avgLine = ChartLimitLine(limit: average)

        avgLine.lineColor = .systemOrange
        avgLine.lineWidth = 2

        avgLine.lineDashLengths = [6, 4]

        avgLine.valueTextColor = .systemOrange

        durationChartView.leftAxis.removeAllLimitLines()
        durationChartView.leftAxis.addLimitLine(avgLine)
    }
    func calculateAverage() -> Double {

        let total = sleepData.reduce(0) { $0 + $1.hoursSlept }
        let average = total / Double(sleepData.count)

        averageDurationLabel.text =
        "Average: \(String(format: "%.1f", average)) hours"

        return average
    }
}
