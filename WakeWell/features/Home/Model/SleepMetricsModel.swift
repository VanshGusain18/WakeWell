import Foundation

struct SleepMetricItem {
    let title: String
    let score: Int
    let maxScore: Int
    let trend: String
}

struct SleepMetricsModel {
    let sleepScore: Int
    let metrics: [SleepMetricItem]
}
