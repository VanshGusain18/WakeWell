import Foundation

struct SleepMetricItem {
    let title: String
    let score: Int
    let maxScore: Int
    let trendPercent: Int    
}

struct SleepMetricsModel {
    let sleepScore: Int
    let metrics: [SleepMetricItem]
}
