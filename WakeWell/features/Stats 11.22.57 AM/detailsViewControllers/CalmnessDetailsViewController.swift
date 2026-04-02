//
//  CalmnessDetailsViewController.swift
//  WakeWell
//
//  Created by geu on 10/03/26.
//

import UIKit
import DGCharts

class CalmnessDetailsViewController: UIViewController {
    @IBOutlet weak var movementChartView: LineChartView!
    @IBOutlet weak var restlessnessChartView: LineChartView!

    @IBOutlet weak var averageMovement: UILabel!
    @IBOutlet weak var averageRestlessScore: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let stats = SleepCalmnessAnalyzer.analyzeWeek()

        averageMovement.text = "Average Movement Score: \(String(format: "%.2f", stats.averageMovement))"
        averageRestlessScore.text = "Average Restlessness Score: \(String(format: "%.2f", stats.averageRestlessnessScore))"

        loadMovementGraph(stats: stats)
        loadRestlessnessTrend(stats: stats)
    }
//movement chart
    private func loadMovementGraph(stats: CalmnessStats) {

        styleChart(movementChartView)

        let entries = stats.movementPerNight.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: $0.element)
        }

        let dataSet = LineChartDataSet(entries: entries, label: "")

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

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: gradientColors,
            locations: nil
        )!

        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)

        movementChartView.data = LineChartData(dataSet: dataSet)

        movementChartView.xAxis.valueFormatter =
            IndexAxisValueFormatter(values: stats.days)

        movementChartView.xAxis.granularity = 1
        movementChartView.xAxis.granularityEnabled = true
        movementChartView.xAxis.axisMinimum = 0
        movementChartView.xAxis.axisMaximum = Double(stats.days.count - 1)

        movementChartView.animate(xAxisDuration: 0.0,yAxisDuration: 1.0,easingOption: .easeOutCubic)
    }
//restless chart
    private func loadRestlessnessTrend(stats: CalmnessStats) {

        styleChart(restlessnessChartView)

        let entries = stats.restlessnessScoreTrend.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: $0.element)
        }

        let dataSet = LineChartDataSet(entries: entries, label: "")

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

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: gradientColors,
            locations: nil
        )!

        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)

        restlessnessChartView.data = LineChartData(dataSet: dataSet)

        restlessnessChartView.xAxis.valueFormatter =
            IndexAxisValueFormatter(values: stats.days)

        restlessnessChartView.xAxis.granularity = 1
        restlessnessChartView.xAxis.granularityEnabled = true
        restlessnessChartView.xAxis.axisMinimum = 0
        restlessnessChartView.xAxis.axisMaximum = Double(stats.days.count - 1)

        restlessnessChartView.animate(xAxisDuration: 0.0,yAxisDuration: 1.0,easingOption: .easeOutCubic)
    }
//common function to style chart
    private func styleChart(_ chart: LineChartView) {

        chart.chartDescription.enabled = false
        chart.legend.enabled = false
        chart.rightAxis.enabled = false

        chart.dragEnabled = false
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.setScaleEnabled(false)

        // X Axis
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = .secondaryLabel
        xAxis.granularity = 1

        // Y Axis
        let leftAxis = chart.leftAxis
        leftAxis.labelTextColor = .secondaryLabel
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = UIColor.systemGray5
        leftAxis.labelCount = 6
    }
}


