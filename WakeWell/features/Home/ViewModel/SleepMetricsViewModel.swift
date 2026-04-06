import UIKit

struct SleepMetricsViewModel {

    struct MetricUI {
        let title: String
        let valueText: String
        let trendText: String
        let trendColor: UIColor
    }

    let sleepScoreText: String
    let metrics: [MetricUI]

    init(model: SleepMetricsModel) {

        sleepScoreText = "Sleep Score: \(model.sleepScore) / 100"

        metrics = model.metrics.map {

            let arrow: String
            let color: UIColor

            if $0.trendPercent > 0 {
                arrow = "↑"
                color = .systemGreen
            } else if $0.trendPercent < 0 {
                arrow = "↓"
                color = .systemRed
            } else {
                arrow = "→"
                color = .systemGray
            }

            let trendText = "\(arrow) \(abs($0.trendPercent))%"

            return MetricUI(
                title: $0.title,
                valueText: "\($0.score) / \($0.maxScore)",
                trendText: trendText,
                trendColor: color
            )
        }
    }
}
