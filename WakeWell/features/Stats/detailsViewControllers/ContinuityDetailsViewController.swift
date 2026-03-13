import DGCharts
import UIKit

final class ContinuityDetailsViewController: UIViewController {

    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var awakeningsValueLabel: UILabel!
    @IBOutlet weak var longestBlockLabel: UILabel!

    @IBOutlet weak var awakeningsNumberCard: UIView!
    
    @IBOutlet weak var longestSleepBlockCard: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sleep Continuity"
        awakeningsNumberCard.layer.cornerRadius = 16
        awakeningsNumberCard.layer.borderWidth = 1
        awakeningsNumberCard.layer.borderColor = UIColor.black.cgColor
        longestSleepBlockCard.layer.cornerRadius = 16
        longestSleepBlockCard.layer.borderWidth = 1
        longestSleepBlockCard.layer.borderColor = UIColor.black.cgColor
        configureChart()
        loadContinuityData()
    }

    // MARK: Chart Setup

    private func configureChart() {

        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false

        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.axisMaximum = 8
        chartView.leftAxis.gridColor = .systemGray5

        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = false
    }

    // MARK: Load Data

    private func loadContinuityData() {

        let stats = SleepContinuityAnalyzer.analyzeWeek()

        // Graph entries
        let entries = stats.awakeningsPerNight.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: Double($0.element))
        }

        let dataSet = LineChartDataSet(entries: entries, label: "")
        dataSet.mode = .cubicBezier
        dataSet.lineWidth = 2.5
        dataSet.setColor(.systemPurple)

        dataSet.drawCirclesEnabled = true
        dataSet.circleRadius = 4
        dataSet.circleColors = [.systemPurple]
        dataSet.circleHoleColor = .white
        dataSet.drawValuesEnabled = false

        chartView.data = LineChartData(dataSet: dataSet)

        chartView.xAxis.valueFormatter =
            IndexAxisValueFormatter(values: stats.days)

        chartView.animate(xAxisDuration: 0.8)

        // Metrics

        awakeningsValueLabel.text =
            String(format: "%.1f awakenings", stats.averageAwakenings)

        longestBlockLabel.text =
            "\(stats.longestSleepBlock) hrs"
    }
}
