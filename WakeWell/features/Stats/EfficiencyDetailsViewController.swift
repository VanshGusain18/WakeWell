import UIKit
import DGCharts

class EfficiencyDetailsViewController: UIViewController {


    @IBOutlet weak var barChartView: BarChartView!
    
    private let metricType: SleepMetricType = .efficiency
   
    override func viewDidLoad() {
        super.viewDidLoad()

        configureChart()
        loadEfficiencyChartData()
    }

    // MARK: - Chart Setup

    private func configureChart() {

        barChartView.chartDescription.enabled = false
        barChartView.rightAxis.enabled = false
        barChartView.legend.enabled = true

        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.gridColor = UIColor.systemGray5

        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false

        barChartView.animate(yAxisDuration: 0.8)
    }


    private func loadEfficiencyChartData() {

        let metricData = EfficiencyDataProvider.weeklyData()

        var timeInBedEntries: [BarChartDataEntry] = []
        var sleepStartEntries: [BarChartDataEntry] = []

        let overlapOffset = 0.15   // 👈 controls overlap amount

        for (index, item) in metricData.enumerated() {

            let baseX = Double(index)

            // Slightly shift bars
            timeInBedEntries.append(
                BarChartDataEntry(
                    x: baseX - overlapOffset,
                    y: item.timeInBed
                )
            )

            sleepStartEntries.append(
                BarChartDataEntry(
                    x: baseX + overlapOffset,
                    y: item.sleepStart
                )
            )
        }

        let timeInBedSet = BarChartDataSet(
            entries: timeInBedEntries,
            label: "Time in Bed"
        )
        timeInBedSet.setColor(.systemIndigo.withAlphaComponent(0.6))
        timeInBedSet.drawValuesEnabled = false

        let sleepStartSet = BarChartDataSet(
            entries: sleepStartEntries,
            label: "Sleep Start"
        )
        sleepStartSet.setColor(.systemTeal)
        sleepStartSet.drawValuesEnabled = false

        let data = BarChartData(dataSets: [timeInBedSet, sleepStartSet])

        data.barWidth = 0.45   // 👈 wider bars = nicer overlap

        barChartView.data = data

        // Axis setup
        barChartView.xAxis.axisMinimum = -0.5
        barChartView.xAxis.axisMaximum = Double(metricData.count) - 0.5
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false

        barChartView.xAxis.valueFormatter =
            IndexAxisValueFormatter(
                values: metricData.map { $0.day }
            )

        barChartView.animate(yAxisDuration: 0.8)
    }



}


