import DGCharts
import UIKit

final class ContinuityDetailsViewController: UIViewController {

    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var awakeningsValueLabel: UILabel!
    @IBOutlet weak var longestBlockLabel: UILabel!

        override func viewDidLoad() {
            super.viewDidLoad()
            styleChart(chartView)
            loadContinuityData()
        }
    private func loadContinuityData() {
        let stats = SleepContinuityAnalyzer.analyzeWeek()

        let entries = stats.awakeningsPerNight.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: Double($0.element))
        }

        let dataSet = LineChartDataSet(entries: entries, label: "")
        configureDataSet(dataSet)

        chartView.data = LineChartData(dataSet: dataSet)
        
        // Match the X-Axis configuration from Duration Screen
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: stats.days)
        chartView.xAxis.granularity = 1
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.axisMaximum = Double(stats.days.count - 1)

        awakeningsValueLabel.text = String(format: "Average Awakenings: %.1f", stats.averageAwakenings)
        longestBlockLabel.text = "Longest Sleep Block: \(stats.longestSleepBlock) hrs"

        chartView.layoutIfNeeded()
        chartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0, easingOption: .easeOutCubic)
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
        leftAxis.axisMaximum = 8 // Scaled for awakenings
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = UIColor.systemGray5
        leftAxis.labelCount = 6
    }

    private func configureDataSet(_ dataSet: LineChartDataSet) {
        dataSet.mode = .cubicBezier
        dataSet.lineWidth = 3
        dataSet.setColor(.systemBlue)
        dataSet.circleRadius = 5
        dataSet.setCircleColor(.systemBlue)
        dataSet.circleHoleColor = .systemBackground
        dataSet.circleHoleRadius = 2.5
        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = true

        let gradientColors = [
            UIColor.systemBlue.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ] as CFArray
        
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: nil) {
            dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
        }
    }
}
