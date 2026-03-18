//
//  SleepStats.swift
//  WakeWell
//
//  Created by geu on 13/02/26.
//
import Foundation

struct SleepStats {
    var duration: Double
    var efficiency: Double
    var architecture: Double
    var consistency: Double
    var calmness: Double
    var continuity: Double
}

struct SleepMetric {
    let type: SleepMetricType
    let displayValue: String
}

enum SleepMetricType: CaseIterable {
    case duration, efficiency, architecture, consistency, calmness, continuity
    
    var title: String {
        switch self {
        case .duration: return "Duration"
        case .efficiency: return "Efficiency"
        case .architecture: return "Architecture"
        case .consistency: return "Consistency"
        case .calmness: return "Calmness"
        case .continuity: return "Continuity"
        }
    }
}

struct MetricValue {
    let raw: Double
}

struct MetricData {
    let day: String
    let value: MetricValue
}
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
