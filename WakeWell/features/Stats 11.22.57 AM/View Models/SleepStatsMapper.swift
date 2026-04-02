//
//  SleepStats.swift
//  WakeWell
//
//  Created by geu on 13/02/26.
//
import Foundation

final class SleepStatsAggregator {
    static func aggregate() -> SleepStats {
        return SleepStats(
            duration: SleepScoreEngine.calculateScore(for: .duration),
            efficiency: SleepScoreEngine.calculateScore(for: .efficiency),
            architecture: SleepScoreEngine.calculateScore(for: .architecture),
            consistency: SleepScoreEngine.calculateScore(for: .consistency),
            calmness: SleepScoreEngine.calculateScore(for: .calmness),
            continuity: SleepScoreEngine.calculateScore(for: .continuity)
        )
    }
}
struct SleepStatsMapper {
    
    static func mapToMetrics(from stats: SleepStats) -> [SleepMetric] {
        
        return [
            SleepMetric(type: .duration,
                        displayValue: "\(stats.duration)"),
            
            SleepMetric(type: .efficiency,
                        displayValue: "\(stats.efficiency)"),
            
            SleepMetric(type: .architecture,
                        displayValue: "\(stats.architecture)"),
            
            SleepMetric(type: .consistency,
                        displayValue: "\(stats.consistency)"),
            
            SleepMetric(type: .calmness,
                        displayValue: "\(stats.calmness)"),
            
            SleepMetric(type: .continuity,
                        displayValue: "\(stats.continuity)")
        ]
    }
}
