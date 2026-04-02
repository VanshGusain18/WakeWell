//
//  ArchitectureDetailsViewController.swift
//  WakeWell
//
//  Created by geu on 10/03/26.
//

import UIKit
import DGCharts

class ArchitectureDetailsViewController: UIViewController {
    
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var deepLabel: UILabel!
    @IBOutlet weak var remLabel: UILabel!
    @IBOutlet weak var lightLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let avg = SleepArchitectureDataProvider.getAllAverages()
        deepLabel.text  = String(format: "Average Deep Sleep : %.0f% %", avg.deep)
        remLabel.text   = String(format: "Average Rem Sleep : %.0f% %", avg.rem)
        lightLabel.text = String(format: "Average Light Sleep : %.0f% %", avg.light)

        setupChart()
        loadWeeklyData()
    }
    private func setupChart() {
        
        barChartView.chartDescription.enabled = false
        barChartView.rightAxis.enabled = false
        
        let yAxis = barChartView.leftAxis
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 100
        
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        
        barChartView.legend.enabled = true
        
        barChartView.animate(yAxisDuration: 1.0)
    }
    private func loadWeeklyData() {
        
        let data = SleepArchitectureDataProvider.getWeeklyData()
        let durationData = SleepDurationModel.getWeeklySleepDuration()
        
        var entries: [BarChartDataEntry] = []
        
        for (index, dayData) in data.enumerated() {
            
            let totalHours = durationData[index].hoursSlept
            
            let deepHours  = totalHours * (dayData.deep / 100.0)
            let remHours   = totalHours * (dayData.rem / 100.0)
            let lightHours = totalHours * (dayData.light / 100.0)
            
            let values = [deepHours, remHours, lightHours]
            
            let entry = BarChartDataEntry(x: Double(index), yValues: values)
            entries.append(entry)
        }
        
        let dataSet = BarChartDataSet(entries: entries, label: "")
        
        dataSet.colors = [
            UIColor(red: 0.0, green: 0.2, blue: 0.8, alpha: 1.0),  
            UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0),
            UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)
        ]
        
        dataSet.stackLabels = ["Deep", "REM", "Light"]
        
        let chartData = BarChartData(dataSet: dataSet)
        chartData.setDrawValues(false)
        
        barChartView.data = chartData
        
        let days = data.map { $0.day }
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        
        let maxSleep = durationData.map { $0.hoursSlept }.max() ?? 10
        barChartView.leftAxis.axisMaximum = maxSleep + 1
    }
}
