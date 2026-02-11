import UIKit
import DGCharts

class SleepScoreChartCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupChart()
    }

    private func setupChart() {
        titleLabel.text = "Sleep Score"
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false
    }

    func configureForWeek() {
        let values = [62, 70, 68, 75, 72, 78, 80]

        let entries = values.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: Double($0.element))
        }

        let dataSet = LineChartDataSet(entries: entries, label: "")
        dataSet.circleRadius = 4
        dataSet.mode = LineChartDataSet.Mode.cubicBezier

        chartView.data = LineChartData(dataSet: dataSet)
    }
}
