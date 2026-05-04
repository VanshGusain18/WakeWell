import UIKit
import DGCharts

class SleepScoreChartCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chartView:  LineChartView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        titleLabel?.font      = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel?.textColor = WakeWellTheme.labelPrimary
        setupChart()
    }

    private func setupChart() {
        chartView.backgroundColor        = .clear
        chartView.chartDescription.enabled  = false
        chartView.legend.enabled            = false
        chartView.rightAxis.enabled         = false
        chartView.dragEnabled               = false
        chartView.pinchZoomEnabled          = false
        chartView.doubleTapToZoomEnabled    = false

        let xAxis                        = chartView.xAxis
        xAxis.labelPosition              = .bottom
        xAxis.drawGridLinesEnabled       = false
        xAxis.labelTextColor             = WakeWellTheme.chartAxisText
        xAxis.granularity                = 1

        let leftAxis                     = chartView.leftAxis
        leftAxis.labelTextColor          = WakeWellTheme.chartAxisText
        leftAxis.axisMinimum             = 0
        leftAxis.axisMaximum             = 100
        leftAxis.drawGridLinesEnabled    = true
        leftAxis.gridColor               = WakeWellTheme.chartGrid
        leftAxis.labelCount              = 6
    }

    func configure(for range: StatsTimeRange) {
        let dataPoints = MetricDataProvider.overallScores(for: range)
        let labels     = dataPoints.map { $0.day }
        let entries    = dataPoints.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: $0.element.value.raw)
        }

        let dataSet                  = LineChartDataSet(entries: entries, label: "")
        dataSet.mode                 = .cubicBezier
        dataSet.lineWidth            = 3
        dataSet.setColor(WakeWellTheme.chartLine)           // amber line
        dataSet.circleRadius         = 5
        dataSet.setCircleColor(WakeWellTheme.chartLine)
        dataSet.circleHoleColor      = WakeWellTheme.cardBackground
        dataSet.circleHoleRadius     = 2.5
        dataSet.drawValuesEnabled    = false

        let gradientColors = [
            WakeWellTheme.chartFillTop.cgColor,
            UIColor.clear.cgColor
        ] as CFArray
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: gradientColors, locations: nil) {
            dataSet.fill              = LinearGradientFill(gradient: gradient, angle: 90)
            dataSet.drawFilledEnabled = true
        }

        chartView.data = LineChartData(dataSet: dataSet)
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        chartView.animate(xAxisDuration: 0.8, yAxisDuration: 1.2)
    }
}
