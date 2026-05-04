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

        sleepScoreText = "Sleep Score: \(model.sleepScore)"

        metrics = model.metrics.map { item in

            let arrow: String
            let color: UIColor

            if item.trendPercent > 0 {
                arrow = "↑"; color = .systemGreen
            } else if item.trendPercent < 0 {
                arrow = "↓"; color = .systemRed
            } else {
                arrow = "→"; color = .systemGray
            }

            return MetricUI(
                title:      item.title,
                valueText:  "\(item.score)",          // just the number, out of 100
                trendText:  "\(arrow) \(abs(item.trendPercent))%",
                trendColor: color
            )
        }
    }
}
