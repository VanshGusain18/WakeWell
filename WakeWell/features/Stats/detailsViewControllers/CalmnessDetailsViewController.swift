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
        title = "Calmness"
        averageMovement.text = "Average Movement Score: \(String(format: "%.2f", SleepCalmnessAnalyzer.analyzeWeek().averageMovement))"
        averageRestlessScore.text = "Average Restlessness Score:\(String(format: "%.2f", SleepCalmnessAnalyzer.analyzeWeek().averageRestlessnessScore))"
        loadMovementGraph()
        loadRestlessnessTrend()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    private func loadMovementGraph() {

        styleChart(movementChartView)

        let stats = SleepCalmnessAnalyzer.analyzeWeek()

        let entries = stats.movementPerNight.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: $0.element)
        }

        let dataSet = LineChartDataSet(entries: entries, label: "")

        dataSet.mode = .cubicBezier
        dataSet.lineWidth = 2.5
        dataSet.setColor(.systemTeal)

        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 4
        dataSet.circleColors = [.systemTeal]
        dataSet.circleHoleColor = .white

        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = true

        let gradientColors = [
            UIColor.systemTeal.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ] as CFArray

        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: nil)!

        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)

        movementChartView.data = LineChartData(dataSet: dataSet)
        movementChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: stats.days)

        movementChartView.xAxis.granularity = 1
        movementChartView.xAxis.granularityEnabled = true
        movementChartView.xAxis.axisMinimum = 0
        movementChartView.xAxis.axisMaximum = Double(stats.days.count - 1)

        movementChartView.xAxis.valueFormatter =
            IndexAxisValueFormatter(values: stats.days)

        movementChartView.animate(xAxisDuration: 1.0)
    }
    private func loadRestlessnessTrend() {

        styleChart(restlessnessChartView)

        let stats = SleepCalmnessAnalyzer.analyzeWeek()

        let entries = stats.restlessnessScoreTrend.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: $0.element)
        }

        let dataSet = LineChartDataSet(entries: entries, label: "")

        dataSet.mode = .cubicBezier
        dataSet.lineWidth = 2.5
        dataSet.setColor(.systemOrange)

        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 4
        dataSet.circleColors = [.systemOrange]
        dataSet.circleHoleColor = .white

        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = true

        let gradientColors = [
            UIColor.systemOrange.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ] as CFArray

        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: nil)!

        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)

        restlessnessChartView.data = LineChartData(dataSet: dataSet)

        restlessnessChartView.xAxis.valueFormatter =
            IndexAxisValueFormatter(values: stats.days)

        restlessnessChartView.animate(xAxisDuration: 1.0)
    }
    private func styleChart(_ chart: LineChartView) {

        chart.backgroundColor = .clear
        chart.drawGridBackgroundEnabled = false
        chart.drawBordersEnabled = false
        
        chart.dragEnabled = true
        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = false
        
        chart.legend.enabled = false
        chart.rightAxis.enabled = false
        
        let leftAxis = chart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 12, weight: .medium)
        leftAxis.labelTextColor = .systemGray
        leftAxis.axisLineColor = .systemGray4
        leftAxis.gridColor = UIColor.systemGray5
        leftAxis.drawAxisLineEnabled = true
        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 12, weight: .medium)
        xAxis.labelTextColor = .systemGray
        xAxis.axisLineColor = .systemGray4
        xAxis.drawGridLinesEnabled = false
        
        chart.extraTopOffset = 10
        chart.extraBottomOffset = 10
    }
}
