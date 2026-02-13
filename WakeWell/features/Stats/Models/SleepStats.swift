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
