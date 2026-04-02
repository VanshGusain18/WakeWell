//
//  SleepStats.swift
//  WakeWell
//
//  Created by geu on 13/02/26.
//
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
    static func mapToMetrics(from stats: SleepStats) -> [SleepMetric] {
        return [
            SleepMetric(type: .duration,     displayValue: "\(Int(stats.duration))"),
            SleepMetric(type: .efficiency,   displayValue: "\(Int(stats.efficiency))"),
            SleepMetric(type: .architecture, displayValue: "\(Int(stats.architecture))"),
            SleepMetric(type: .consistency,  displayValue: "\(Int(stats.consistency))"),
            SleepMetric(type: .calmness,     displayValue: "\(Int(stats.calmness))"),
            SleepMetric(type: .continuity,   displayValue: "\(Int(stats.continuity))")
        ]
    }
}
