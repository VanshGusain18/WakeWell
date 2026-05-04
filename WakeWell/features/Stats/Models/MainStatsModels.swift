import Foundation

struct MetricValue {
    let raw: Double
}

struct MetricData {
    let day:   String
    let value: MetricValue
}

struct SleepStats {
    var duration:     Double
    var efficiency:   Double
    var architecture: Double
    var consistency:  Double
    var calmness:     Double
    var continuity:   Double
}

struct SleepMetric {
    let type:         SleepMetricType
    let displayValue: String
    let trendPercent: Int       // % change vs previous period; 0 = no data
}

enum SleepMetricType: CaseIterable {
    case duration, efficiency, architecture, consistency, calmness, continuity

    var title: String {
        switch self {
        case .duration:     return "Duration"
        case .efficiency:   return "Efficiency"
        case .architecture: return "Architecture"
        case .consistency:  return "Consistency"
        case .calmness:     return "Calmness"
        case .continuity:   return "Continuity"
        }
    }
}
