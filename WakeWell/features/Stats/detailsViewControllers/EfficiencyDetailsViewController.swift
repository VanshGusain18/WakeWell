import UIKit
import DGCharts

class EfficiencyDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var efficiencyChartView: LineChartView!
    @IBOutlet weak var sleepVsBedChartView: BarChartView!
    
    var efficiencyData: [EfficiencyData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Sleep Efficiency"
        descriptionLabel.text = "Sleep efficiency measures how much of your time in bed is actually spent sleeping."

        efficiencyData = EfficiencyModel.getWeeklyEfficiency()

        setupEfficiencyChart()
        setupSleepVsBedChart()
    }
    func setupEfficiencyChart() {

        var entries: [ChartDataEntry] = []

        for (index, data) in efficiencyData.enumerated() {
            entries.append(
                ChartDataEntry(x: Double(index), y: data.efficiency)
            )
        }

        // Dataset
        let dataSet = LineChartDataSet(entries: entries, label: "Efficiency")

        dataSet.setColor(.systemBlue)
        dataSet.lineWidth = 2.5
        dataSet.mode = .cubicBezier

        dataSet.setCircleColor(.systemBlue)
        dataSet.circleRadius = 4
        dataSet.circleHoleRadius = 2
        dataSet.drawCircleHoleEnabled = true

        dataSet.drawValuesEnabled = false

        // Gradient fill
        dataSet.drawFilledEnabled = true
        let gradientColors = [
            UIColor.systemBlue.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor
        ] as CFArray

        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: nil)!
        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)

        let chartData = LineChartData(dataSet: dataSet)
        efficiencyChartView.data = chartData

        // X Axis (Day Labels)
        let days = efficiencyData.map { $0.day }

        let xAxis = efficiencyChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1
        xAxis.labelFont = .systemFont(ofSize: 12, weight: .medium)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        xAxis.labelCount = days.count
        xAxis.axisMinimum = -0.5
        xAxis.axisMaximum = Double(days.count) - 0.5

        // Left Axis
        let leftAxis = efficiencyChartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 100
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = .systemGray5
        leftAxis.labelFont = .systemFont(ofSize: 12)

        // Disable right axis
        efficiencyChartView.rightAxis.enabled = false

        // Remove legend
        efficiencyChartView.legend.enabled = false

        // Remove description
        efficiencyChartView.chartDescription.enabled = false

        // Animation
        efficiencyChartView.animate(xAxisDuration: 1.2)
    }
    func setupSleepVsBedChart() {

        var sleepEntries: [BarChartDataEntry] = []
        var bedEntries: [BarChartDataEntry] = []

        for (index, data) in efficiencyData.enumerated() {

            sleepEntries.append(
                BarChartDataEntry(x: Double(index), y: data.timeAsleep)
            )

            bedEntries.append(
                BarChartDataEntry(x: Double(index), y: data.timeInBed)
            )
        }

        let sleepSet = BarChartDataSet(entries: sleepEntries, label: "Sleep")
        sleepSet.setColor(.systemBlue)
        sleepSet.valueFont = .systemFont(ofSize: 11)
        sleepSet.drawValuesEnabled = false

        let bedSet = BarChartDataSet(entries: bedEntries, label: "In Bed")
        bedSet.setColor(.systemGray3)
        bedSet.valueFont = .systemFont(ofSize: 11)
        bedSet.drawValuesEnabled = false

        let chartData = BarChartData(dataSets: [sleepSet, bedSet])

        let barWidth = 0.35
        let groupSpace = 0.25
        let barSpace = 0.05

        chartData.barWidth = barWidth

        sleepVsBedChartView.data = chartData

        sleepVsBedChartView.xAxis.axisMinimum = 0
        sleepVsBedChartView.xAxis.axisMaximum =
            Double(efficiencyData.count)

        chartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)

        let days = efficiencyData.map { $0.day }

        let xAxis = sleepVsBedChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1
        xAxis.labelFont = .systemFont(ofSize: 12, weight: .medium)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        xAxis.labelCount = days.count
        xAxis.centerAxisLabelsEnabled = true

        let leftAxis = sleepVsBedChartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = .systemGray5
        leftAxis.labelFont = .systemFont(ofSize: 12)

        sleepVsBedChartView.rightAxis.enabled = false

        let legend = sleepVsBedChartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.font = .systemFont(ofSize: 12)

        sleepVsBedChartView.chartDescription.enabled = false

        sleepVsBedChartView.animate(yAxisDuration: 1.2)
    }
}


