//
//  DurationDetailViewController.swift
//  WakeWell
//
//  Created by geu on 12/02/26.
//


import UIKit
import DGCharts

class DurationDetailViewController: UIViewController {

    private let chartView = BarChartView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Duration Details"

        setupChart()
        setData()
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

        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = false
    }

    private func setData() {

        // Example sleep duration data (in hours)
        let durations = [6.5, 7.2, 5.8, 8.0, 6.9, 7.5, 8.3]

        let entries = durations.enumerated().map {
            BarChartDataEntry(x: Double($0.offset), y: $0.element)
        }

        let dataSet = BarChartDataSet(entries: entries, label: "Sleep Duration")
        
        dataSet.colors = [.systemBlue]

        let data = BarChartData(dataSet: dataSet)
        data.barWidth = 0.6

        chartView.data = data

        // X-axis labels
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(
            values: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        )

        chartView.animate(yAxisDuration: 1.2)
    }
}
