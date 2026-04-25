import UIKit
import DGCharts

class LineChartTableViewCell: UITableViewCell {

    @IBOutlet weak var glassContainer: UIView!
    @IBOutlet weak var titleLabel:     UILabel!
    @IBOutlet weak var lineChartView:  LineChartView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        glassContainer.backgroundColor = WakeWellTheme.background
        glassContainer.layer.cornerRadius = 0
        glassContainer.layer.borderWidth = 0
        glassContainer.layer.shadowOpacity = 0

        titleLabel.font      = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = WakeWellTheme.labelPrimary
        setupChartAppearance()
    }

    private func setupChartAppearance() {
        lineChartView.backgroundColor         = .clear
        lineChartView.rightAxis.enabled       = false
        lineChartView.legend.enabled          = false
        lineChartView.chartDescription.enabled = false

        let xAxis = lineChartView.xAxis
        xAxis.labelPosition       = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.labelFont           = .systemFont(ofSize: 10, weight: .medium)
        xAxis.labelTextColor      = WakeWellTheme.chartAxisText
        xAxis.granularity         = 1
        xAxis.centerAxisLabelsEnabled = false

        let leftAxis = lineChartView.leftAxis
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor            = WakeWellTheme.chartGrid
        leftAxis.labelFont            = .systemFont(ofSize: 10)
        leftAxis.labelTextColor       = WakeWellTheme.chartAxisText
        leftAxis.axisMinimum          = 0

        lineChartView.animate(yAxisDuration: 1.0, easingOption: .easeOutCubic)
    }

    func configure(title: String, dataSets: [LineChartDataSetModel], xAxisLabels: [String]) {
        titleLabel.text = title
        guard !dataSets.isEmpty else { lineChartView.data = nil; return }

        let chartDataSets: [LineChartDataSet] = dataSets.map { model in
            let entries = model.values.map { ChartDataEntry(x: $0.xIndex, y: $0.value) }
            let set = LineChartDataSet(entries: entries, label: model.label)
            set.setColor(WakeWellTheme.chartLine)
            set.lineWidth          = 3
            set.mode               = .cubicBezier
            set.drawValuesEnabled  = false
            set.drawCirclesEnabled = true
            set.circleRadius       = 4
            set.setCircleColor(WakeWellTheme.chartLine)
            set.circleHoleColor    = WakeWellTheme.background
            set.circleHoleRadius   = 2
            let gc = [WakeWellTheme.chartFillTop.cgColor, UIColor.clear.cgColor] as CFArray
            if let g = CGGradient(colorsSpace: nil, colors: gc, locations: nil) {
                set.fill = LinearGradientFill(gradient: g, angle: 90)
                set.drawFilledEnabled = true
            }
            return set
        }

        let chartData = LineChartData(dataSets: chartDataSets)
        lineChartView.data = chartData
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
        lineChartView.xAxis.axisMinimum    = 0
        lineChartView.xAxis.axisMaximum    = Double(xAxisLabels.count - 1)
        lineChartView.notifyDataSetChanged()
        lineChartView.animate(yAxisDuration: 1.0, easingOption: .easeOutCubic)
    }

    override func prepareForReuse() { super.prepareForReuse(); lineChartView.data = nil }
}
