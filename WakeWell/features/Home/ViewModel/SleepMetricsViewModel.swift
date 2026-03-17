import Foundation

struct SleepMetricsViewModel {

    struct MetricUI {
        let title: String
        let valueText: String
        let trendText: String   // NEW
    }

    let sleepScoreText: String
    let metrics: [MetricUI]

    init(model: SleepMetricsModel) {

        sleepScoreText = "Sleep Score: \(model.sleepScore) / 100"

        metrics = model.metrics.map {
            MetricUI(
                title: $0.title,
                valueText: "\($0.score) / \($0.maxScore)",
                trendText: $0.trend
            )
        }
    }
}
