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
        chartView.chartDescription.enabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false
        chartView.dragEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false

        // X Axis styling
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = .secondaryLabel
        xAxis.granularity = 1

        // Y Axis styling
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = .secondaryLabel
        leftAxis.axisMinimum = 50
        leftAxis.axisMaximum = 100
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = UIColor.systemGray5
        leftAxis.labelCount = 6
    }

    func configureForWeek() {

        let values = [62, 70, 68, 75, 72, 78, 80]

        let entries = values.enumerated().map {
            ChartDataEntry(x: Double($0.offset), y: Double($0.element))
        }

        let dataSet = LineChartDataSet(entries: entries, label: "")

        dataSet.mode = .cubicBezier
        dataSet.lineWidth = 3
        dataSet.setColor(.systemIndigo)

        dataSet.circleRadius = 5
        dataSet.setCircleColor(.systemIndigo)
        dataSet.circleHoleColor = .systemBackground
        dataSet.circleHoleRadius = 2.5

        dataSet.drawValuesEnabled = false

        let gradientColors = [
            UIColor.systemIndigo.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor
        ] as CFArray

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: gradientColors,
            locations: nil
        )!

        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
        dataSet.drawFilledEnabled = true

        let data = LineChartData(dataSet: dataSet)
        chartView.data = data

        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(
            values: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        )

        chartView.animate(xAxisDuration: 0.8, yAxisDuration: 1.2)
    }
}


   

