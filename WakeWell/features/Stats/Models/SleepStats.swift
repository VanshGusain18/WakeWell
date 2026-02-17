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
struct SleepMetric{
    let type: SleepMetricType
    let displayValue: String
}
enum SleepMetricType {
    case duration
    case efficiency
    case architecture
    case consistency
    case calmness
    case continuity
    
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

    var chartValue: Double {
        raw
    }
}
struct MetricData {
    let day: String
    let value: MetricValue
}

final class SleepStatsAggregator {

    static func aggregate() -> SleepStats {

        let duration = average(.duration)
        let efficiency = average(.efficiency)
        let architecture = average(.architecture)
        let consistency = average(.consistency)
        let calmness = average(.calmness)
        let continuity = average(.continuity)

        return SleepStats(
            duration: duration,
            efficiency: efficiency,
            architecture: architecture,
            consistency: consistency,
            calmness: calmness,
            continuity: continuity
        )
    }

    private static func average(_ metric: SleepMetricType) -> Double {
        let data = MetricDataProvider.weeklyData(for: metric)
        let values = data.map { $0.value.raw }
        return values.reduce(0, +) / Double(values.count)
    }
}
