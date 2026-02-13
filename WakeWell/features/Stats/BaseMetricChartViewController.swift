import UIKit
import DGCharts

final class BaseMetricChartViewController: UIViewController {

    private var chartView: ChartViewBase!
    private let metricType: SleepMetricType

    init(metricType: SleepMetricType) {
        self.metricType = metricType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = metricType.title

        setupChartView()
        loadChartData()
    }

    private func setupChartView() {

        switch metricType {
        case .duration:
            chartView = LineChartView()

        default:
            chartView = BarChartView()
        }

        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            chartView.heightAnchor.constraint(equalToConstant: 350)
        ])

        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
    }
    private func loadChartData() {

        let metricData = MetricDataProvider.weeklyData(for: metricType)

        let entries = metricData.enumerated().map {
            ChartDataEntry(
                x: Double($0.offset),
                y: $0.element.value.chartValue
            )
        }
        guard let lineChart = chartView as? LineChartView else { return }

        let dataSet = LineChartDataSet(entries: entries, label: "")

        dataSet.mode = .cubicBezier
        dataSet.lineWidth = 2.5
        dataSet.setColor(.systemIndigo)

        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 4
        dataSet.circleColors = [.systemIndigo]
        dataSet.circleHoleColor = .white
        dataSet.drawValuesEnabled = false

        dataSet.drawFilledEnabled = false
        let zoneEntries = entries.map {
            ChartDataEntry(x: $0.x, y: 9)
        }
        let average = entries.map { $0.y }.reduce(0, +) / Double(entries.count)
        let zoneDataSet = LineChartDataSet(entries: zoneEntries, label: "")

        zoneDataSet.drawCirclesEnabled = false
        zoneDataSet.drawValuesEnabled = false
        zoneDataSet.lineWidth = 0
        zoneDataSet.setColor(.clear)

        zoneDataSet.drawFilledEnabled = true
        zoneDataSet.fillColor = UIColor.systemGreen.withAlphaComponent(0.15)

        // This tells it to fill down to 7
        zoneDataSet.fillFormatter = DefaultFillFormatter { _, _ in
            return 7
        }
        let data = LineChartData(dataSets: [zoneDataSet, dataSet])

        lineChart.data = data


        lineChart.leftAxis.removeAllLimitLines()

        let lower = ChartLimitLine(limit: 7)
        let upper = ChartLimitLine(limit: 9)

        lower.lineWidth = 0
        upper.lineWidth = 0

        lineChart.leftAxis.addLimitLine(lower)
        lineChart.leftAxis.addLimitLine(upper)

        lineChart.leftAxis.drawLimitLinesBehindDataEnabled = true
        

        let averageLine = ChartLimitLine(limit: average, label: "Avg")
        averageLine.lineColor = .systemOrange
        averageLine.lineWidth = 2
        averageLine.lineDashLengths = [6, 4]
        averageLine.labelPosition = .rightTop

        lineChart.leftAxis.addLimitLine(averageLine)

        lineChart.chartDescription.enabled = false
        lineChart.legend.enabled = false
        lineChart.rightAxis.enabled = false

        lineChart.leftAxis.axisMinimum = 0
        lineChart.leftAxis.axisMaximum = 12
        lineChart.leftAxis.gridColor = UIColor.systemGray5

        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(
            values: metricData.map { $0.day }
        )

        lineChart.animate(xAxisDuration: 0.8)
    }
}
