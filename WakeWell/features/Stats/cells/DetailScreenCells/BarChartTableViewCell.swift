import UIKit
import DGCharts

class BarChartTableViewCell: UITableViewCell {

    @IBOutlet weak var glassContainer: UIView!
    @IBOutlet weak var titleLabel:     UILabel!
    @IBOutlet weak var barChartView:   BarChartView!
    private let emptyStateLabel = UILabel()

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
        setupEmptyState()
    }

    private func setupChartAppearance() {
        barChartView.backgroundColor         = .clear
        barChartView.rightAxis.enabled       = false
        barChartView.chartDescription.enabled = false

        let xAxis = barChartView.xAxis
        xAxis.labelPosition        = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity          = 1
        xAxis.labelFont            = .systemFont(ofSize: 10, weight: .medium)
        xAxis.labelTextColor       = WakeWellTheme.chartAxisText

        let leftAxis = barChartView.leftAxis
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor            = WakeWellTheme.chartGrid
        leftAxis.labelTextColor       = WakeWellTheme.chartAxisText
        leftAxis.axisMinimum          = 0

        let legend = barChartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment   = .bottom
        legend.orientation         = .horizontal
        legend.drawInside          = false
        legend.font                = .systemFont(ofSize: 11)
        legend.textColor           = WakeWellTheme.labelSecondary
    }

    private func setupEmptyState() {
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        emptyStateLabel.textColor = WakeWellTheme.labelSecondary
        emptyStateLabel.text = "No chart data yet.\nOnce the watch collects enough nights, this view will populate automatically."
        emptyStateLabel.isHidden = true
        contentView.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emptyStateLabel.centerYAnchor.constraint(equalTo: barChartView.centerYAnchor)
        ])
    }

    func configure(title: String, dataSets: [BarChartDataSetModel], xAxisLabels: [String]) {
        titleLabel.text = title
        guard !dataSets.isEmpty else {
            barChartView.isHidden = false
            barChartView.alpha = 0.25
            barChartView.data = placeholderChartData()
            emptyStateLabel.isHidden = false
            return
        }

        barChartView.isHidden = false
        barChartView.alpha = 1.0
        emptyStateLabel.isHidden = true

        let palette: [UIColor] = [
            WakeWellTheme.accentPurple,
            WakeWellTheme.accentGold,
            WakeWellTheme.accentPurple.withAlphaComponent(0.6)
        ]

        let chartDataSets: [BarChartDataSet] = dataSets.enumerated().map { idx, model in
            let entries = model.values.map { BarChartDataEntry(x: $0.xIndex, y: $0.value) }
            let set = BarChartDataSet(entries: entries, label: model.label)
            set.setColor(palette[idx % palette.count])
            set.drawValuesEnabled = false
            return set
        }

        let chartData = BarChartData(dataSets: chartDataSets)
        let groupCount = Double(xAxisLabels.count)

        if dataSets.count > 1 {
            let groupSpace = 0.3; let barSpace = 0.05
            let barWidth = (1.0 - groupSpace) / Double(dataSets.count) - barSpace
            chartData.barWidth = barWidth
            chartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
            barChartView.xAxis.axisMinimum = 0
            barChartView.xAxis.axisMaximum = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * groupCount
            barChartView.xAxis.centerAxisLabelsEnabled = true
        } else {
            let bw = 0.5
            chartData.barWidth = bw
            barChartView.xAxis.axisMinimum = -bw / 2
            barChartView.xAxis.axisMaximum = (groupCount - 1) + bw / 2
            barChartView.xAxis.centerAxisLabelsEnabled = false
        }

        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
        barChartView.xAxis.labelCount     = xAxisLabels.count
        barChartView.xAxis.granularity    = 1
        barChartView.data = chartData
        barChartView.notifyDataSetChanged()
        barChartView.animate(yAxisDuration: 1.0, easingOption: .easeOutCubic)
    }

    private func placeholderChartData() -> BarChartData {
        let entries = [
            BarChartDataEntry(x: 0, y: 28),
            BarChartDataEntry(x: 1, y: 42),
            BarChartDataEntry(x: 2, y: 36),
            BarChartDataEntry(x: 3, y: 50)
        ]
        let set = BarChartDataSet(entries: entries, label: "")
        set.setColor(WakeWellTheme.labelTertiary)
        set.drawValuesEnabled = false
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["", "", "", ""])
        barChartView.xAxis.labelCount = 4
        return BarChartData(dataSet: set)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        barChartView.data = nil
        barChartView.isHidden = false
        barChartView.alpha = 1.0
        emptyStateLabel.isHidden = true
    }
}
