import UIKit
import DGCharts

class SleepScoreChartCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chartView:  LineChartView!
    private let emptyStateLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        titleLabel?.font      = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel?.textColor = WakeWellTheme.labelPrimary
        setupChart()
        setupEmptyState()
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

    private func setupEmptyState() {
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        emptyStateLabel.textColor = WakeWellTheme.labelSecondary
        emptyStateLabel.text = "No sleep data yet.\nWear your Apple Watch tonight to start building your analytics."
        emptyStateLabel.isHidden = true
        contentView.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emptyStateLabel.centerYAnchor.constraint(equalTo: chartView.centerYAnchor)
        ])
    }

    func configure(for range: StatsTimeRange) {
        let dataPoints = MetricDataProvider.overallScores(for: range)
        guard !dataPoints.isEmpty else {
            chartView.data = nil
            chartView.isHidden = true
            emptyStateLabel.isHidden = false
            return
        }

        chartView.isHidden = false
        emptyStateLabel.isHidden = true
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

    override func prepareForReuse() {
        super.prepareForReuse()
        chartView.data = nil
        chartView.isHidden = false
        emptyStateLabel.isHidden = true
    }
}
