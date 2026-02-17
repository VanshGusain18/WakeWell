//
//  DurationDetailsViewController.swift
//  WakeWell
//
//  Created by geu on 14/02/26.
//
import DGCharts
import UIKit


final class DurationDetailsViewController: UIViewController {

    @IBOutlet weak var chartView: LineChartView!

    private let metricType: SleepMetricType

    init(metricType: SleepMetricType) {
        self.metricType = metricType
        super.init(nibName: "DurationDetailsViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = metricType.title

        configureChart()
        loadChartData()
    }

    // MARK: - Chart Appearance

    private func configureChart() {

        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false

        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.axisMaximum = 12
        chartView.leftAxis.gridColor = UIColor.systemGray5

        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = false
    }

    // MARK: - Load Data

    private func loadChartData() {

        let metricData = MetricDataProvider.weeklyData(for: metricType)

        let entries = metricData.enumerated().map {
            ChartDataEntry(
                x: Double($0.offset),
                y: $0.element.value.chartValue
            )
        }

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

        // Ideal Zone 7–9
        let zoneEntries = entries.map {
            ChartDataEntry(x: $0.x, y: 9)
        }

        let zoneDataSet = LineChartDataSet(entries: zoneEntries, label: "")
        zoneDataSet.drawCirclesEnabled = false
        zoneDataSet.drawValuesEnabled = false
        zoneDataSet.lineWidth = 0
        zoneDataSet.setColor(.clear)
        zoneDataSet.drawFilledEnabled = true
        zoneDataSet.fillColor = UIColor.systemGreen.withAlphaComponent(0.15)
        zoneDataSet.fillFormatter = DefaultFillFormatter { _, _ in
            return 7
        }

        chartView.data = LineChartData(dataSets: [zoneDataSet, dataSet])

        // Average line
        let average = entries.map { $0.y }.reduce(0, +) / Double(entries.count)

        let avgLine = ChartLimitLine(limit: average, label: "Avg")
        avgLine.lineColor = .systemOrange
        avgLine.lineWidth = 2
        avgLine.lineDashLengths = [6, 4]
        avgLine.labelPosition = .rightTop

        chartView.leftAxis.removeAllLimitLines()
        chartView.leftAxis.addLimitLine(avgLine)

        chartView.xAxis.valueFormatter =
            IndexAxisValueFormatter(values: metricData.map { $0.day })

        chartView.animate(xAxisDuration: 0.8)
    }
}
