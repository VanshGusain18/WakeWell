import UIKit
import DGCharts

final class BaseMetricChartViewController: UIViewController {

    private let chartView = BarChartView()
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

        setupChart()
        loadData()
    }

  
    private func setupChart() {
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
        chartView.rightAxis.enabled = false

        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.drawGridLinesEnabled = true

        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.granularity = 1
    }


    private func loadData() {

        let metricData = MetricDataProvider.weeklyData(for: metricType)

        let entries = metricData.enumerated().map {
            BarChartDataEntry(
                x: Double($0.offset),
                y: $0.element.value.chartValue
            )
        }

        let dataSet = BarChartDataSet(entries: entries, label: metricType.title)
        dataSet.colors = [.systemBlue]
        dataSet.valueFont = .systemFont(ofSize: 11, weight: .medium)

        let data = BarChartData(dataSet: dataSet)
        data.barWidth = 0.6

        chartView.data = data

        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(
            values: metricData.map { $0.day }
        )

        chartView.animate(yAxisDuration: 1.1)
    }
}
