import UIKit

struct SleepMetricsViewModel {

    struct MetricUI {
        let title:      String
        let valueText:  String   // plain score e.g. "82", no "/100"
        let trendText:  String
        let trendColor: UIColor
    }

    let sleepScoreText: String
    let metrics: [MetricUI]

    init(model: SleepMetricsModel) {

        sleepScoreText = model.hasData ? "Sleep Score: \(model.sleepScore)" : "Sleep Score: --"

        metrics = model.metrics.map { item in
            let arrow: String
            let color: UIColor
            let valueText: String
            let trendText: String

            if model.hasData {
                if item.trendPercent > 0 {
                    arrow = "↑"; color = .systemGreen
                } else if item.trendPercent < 0 {
                    arrow = "↓"; color = .systemRed
                } else {
                    arrow = "→"; color = .systemGray
                }
                valueText = "\(item.score)"
                trendText = "\(arrow) \(abs(item.trendPercent))%"
            } else {
                arrow = "•"
                color = WakeWellTheme.labelTertiary
                valueText = "—"
                trendText = "No data"
            }

            return MetricUI(
                title:      item.title,
                valueText:  valueText,
                trendText:  trendText,
                trendColor: color
            )
        }
    }
}
