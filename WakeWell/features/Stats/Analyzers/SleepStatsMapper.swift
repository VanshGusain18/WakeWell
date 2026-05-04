import Foundation

final class SleepStatsAggregator {
    static func aggregate(for range: StatsTimeRange) -> SleepStats {
        SleepStats(
            duration:     SleepScoreEngine.calculateScore(for: .duration,     range: range),
            efficiency:   SleepScoreEngine.calculateScore(for: .efficiency,   range: range),
            architecture: SleepScoreEngine.calculateScore(for: .architecture, range: range),
            consistency:  SleepScoreEngine.calculateScore(for: .consistency,  range: range),
            calmness:     SleepScoreEngine.calculateScore(for: .calmness,     range: range),
            continuity:   SleepScoreEngine.calculateScore(for: .continuity,   range: range)
        )
    }
}

struct SleepStatsMapper {

    /// Map current stats to metrics, computing trend vs the previous period.
    /// previousRange: the range used as baseline (e.g. .month when current is .week).
    static func mapToMetrics(from stats: SleepStats,
                              previousStats: SleepStats? = nil) -> [SleepMetric] {

        func trend(current: Double, previous: Double?) -> Int {
            guard let prev = previous, prev > 0 else { return 0 }
            return Int(((current - prev) / prev * 100).rounded())
        }

        return [
            SleepMetric(type: .duration,
                        displayValue: "\(Int(stats.duration.rounded()))",
                        trendPercent: trend(current: stats.duration,
                                            previous: previousStats?.duration)),
            SleepMetric(type: .efficiency,
                        displayValue: "\(Int(stats.efficiency.rounded()))",
                        trendPercent: trend(current: stats.efficiency,
                                            previous: previousStats?.efficiency)),
            SleepMetric(type: .architecture,
                        displayValue: "\(Int(stats.architecture.rounded()))",
                        trendPercent: trend(current: stats.architecture,
                                            previous: previousStats?.architecture)),
            SleepMetric(type: .consistency,
                        displayValue: "\(Int(stats.consistency.rounded()))",
                        trendPercent: trend(current: stats.consistency,
                                            previous: previousStats?.consistency)),
            SleepMetric(type: .calmness,
                        displayValue: "\(Int(stats.calmness.rounded()))",
                        trendPercent: trend(current: stats.calmness,
                                            previous: previousStats?.calmness)),
            SleepMetric(type: .continuity,
                        displayValue: "\(Int(stats.continuity.rounded()))",
                        trendPercent: trend(current: stats.continuity,
                                            previous: previousStats?.continuity))
        ]
    }
}
