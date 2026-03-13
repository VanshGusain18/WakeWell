//
//  ArchitectureDetailsViewController.swift
//  WakeWell
//
//  Created by geu on 10/03/26.
//

import UIKit
import DGCharts

class ArchitectureDetailsViewController: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!

    @IBOutlet weak var deepLabel: UILabel!
    @IBOutlet weak var remLabel: UILabel!
    @IBOutlet weak var lightLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Architecture"

        setupChart()
        loadData()
    }
    private func setupChart() {

        pieChartView.holeRadiusPercent = 0.4
        pieChartView.transparentCircleRadiusPercent = 0.45

        pieChartView.usePercentValuesEnabled = true

        pieChartView.entryLabelFont = .systemFont(ofSize: 12)
        pieChartView.entryLabelColor = .label

        pieChartView.legend.enabled = false

        pieChartView.animate(yAxisDuration: 1.0)
    }
    private func loadData() {

        let architecture = SleepArchitecture.sampleData()

        deepLabel.text = "Deep Sleep   \(Int(architecture.deepSleep))%"
        remLabel.text = "REM Sleep    \(Int(architecture.remSleep))%"
        lightLabel.text = "Light Sleep  \(Int(architecture.lightSleep))%"

        let entries = [
            PieChartDataEntry(value: architecture.deepSleep, label: "Deep"),
            PieChartDataEntry(value: architecture.remSleep, label: "REM"),
            PieChartDataEntry(value: architecture.lightSleep, label: "Light")
        ]

        let dataSet = PieChartDataSet(entries: entries)

        dataSet.colors = [
            .systemIndigo,
            .systemPurple,
            .systemTeal
        ]

        dataSet.sliceSpace = 3

        let data = PieChartData(dataSet: dataSet)

        let formatter = DefaultValueFormatter(decimals: 0)
        data.setValueFormatter(formatter)

        pieChartView.data = data
    }
}
