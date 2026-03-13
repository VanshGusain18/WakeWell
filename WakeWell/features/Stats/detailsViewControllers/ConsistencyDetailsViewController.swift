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

        title = "Consistency"

        setupCharts()
        loadConsistencyData()
    }
    private func setupCharts() {
        
        configureChart(chart: bedtimeChartView)
        configureChart(chart: wakeChartView)
    }

    private func configureChart(chart: LineChartView) {

        chart.backgroundColor = .clear
        chart.drawGridBackgroundEnabled = false
        chart.drawBordersEnabled = false
        
        chart.dragEnabled = true
        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = false
        
        chart.animate(xAxisDuration: 1.2, easingOption: .easeInOutQuart)
        
        chart.legend.enabled = false
        
        chart.rightAxis.enabled = false
        
        let leftAxis = chart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 12, weight: .medium)
        leftAxis.labelTextColor = .gray
        leftAxis.axisLineColor = .lightGray
        leftAxis.gridColor = UIColor.systemGray5
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawGridLinesEnabled = true
        
        let xAxis = chart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 12, weight: .medium)
        xAxis.labelTextColor = .gray
        xAxis.axisLineColor = .lightGray
        xAxis.gridColor = .clear
        xAxis.drawGridLinesEnabled = false
        
        chart.extraTopOffset = 10
        chart.extraBottomOffset = 10
    }
    private func loadConsistencyData() {

        let data = SleepConsistency.weeklyData()

        var bedtimeEntries: [ChartDataEntry] = []
        var wakeEntries: [ChartDataEntry] = []

        for (index, item) in data.enumerated() {

            bedtimeEntries.append(
                ChartDataEntry(x: Double(index), y: item.bedtime)
            )

            wakeEntries.append(
                ChartDataEntry(x: Double(index), y: item.wakeTime)
            )
        }

        let bedtimeSet = LineChartDataSet(entries: bedtimeEntries)
        bedtimeSet.colors = [.systemPurple]
        bedtimeSet.circleColors = [.systemPurple]
        bedtimeSet.lineWidth = 2

        let wakeSet = LineChartDataSet(entries: wakeEntries)
        wakeSet.colors = [.systemTeal]
        wakeSet.circleColors = [.systemTeal]
        wakeSet.lineWidth = 2

        bedtimeChartView.data = LineChartData(dataSet: bedtimeSet)
        wakeChartView.data = LineChartData(dataSet: wakeSet)
    }
}
