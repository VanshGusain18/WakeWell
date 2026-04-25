import Foundation

// Each metric is now a plain score out of 100 — no maxScore needed.
struct SleepMetricItem {
    let title:        String
    let score:        Int      // 0–100
    let trendPercent: Int
}

struct SleepMetricsModel {
    let sleepScore: Int
    let metrics:    [SleepMetricItem]
}
