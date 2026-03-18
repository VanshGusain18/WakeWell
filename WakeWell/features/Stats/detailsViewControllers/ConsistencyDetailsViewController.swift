//
//  ConsistencyDetailsViewController.swift
//  WakeWell
//
//  Created by geu on 12/03/26.
//

import UIKit
import DGCharts

class ConsistencyDetailsViewController: UIViewController {

    @IBOutlet weak var bedtimeChartView: LineChartView!
    @IBOutlet weak var wakeChartView: LineChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        styleChart(bedtimeChartView)
        styleChart(wakeChartView)
        loadConsistencyData()
    }
    
    private func loadConsistencyData() {
        let data = SleepConsistency.weeklyData()
        let days = data.map { $0.day }
        let bedtimeEntries = data.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: $0.element.bedtime)
        }

        let wakeEntries = data.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: $0.element.wakeTime)
        }

        let bedtimeSet = createDataSet(entries: bedtimeEntries, color: .systemBlue)

        let wakeSet = createDataSet(entries: wakeEntries, color: .systemBlue)

        bedtimeChartView.data = LineChartData(dataSet: bedtimeSet)
        wakeChartView.data = LineChartData(dataSet: wakeSet)

        bedtimeChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        wakeChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)

        [bedtimeChartView, wakeChartView].forEach { chart in
            chart.xAxis.granularity = 1
            chart.xAxis.axisMinimum = 0
            chart.xAxis.axisMaximum = Double(days.count - 1)

            chart.animate(xAxisDuration: 0.0, yAxisDuration: 1.0, easingOption: .easeOutCubic)
        }
    }

    private func createDataSet(entries: [ChartDataEntry], color: UIColor) -> LineChartDataSet {

        let dataSet = LineChartDataSet(entries: entries, label: "")

        dataSet.mode = .cubicBezier
        dataSet.lineWidth = 3
        dataSet.setColor(color)

        dataSet.circleRadius = 5
        dataSet.setCircleColor(color)
        dataSet.circleHoleColor = .systemBackground
        dataSet.circleHoleRadius = 2.5

        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = true

        let gradientColors = [
            color.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ] as CFArray

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: gradientColors,
            locations: nil
        )!

        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)

        return dataSet
    }

    // MARK: - Shared Chart Style (MATCHES SleepScoreChartCell)
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
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = UIColor.systemGray5
        leftAxis.labelCount = 6
    }
}

