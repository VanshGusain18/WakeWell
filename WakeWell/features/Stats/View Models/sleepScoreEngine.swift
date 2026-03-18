//
//  sleepScoreEngine.swift
//  WakeWell
//
//  Created by geu on 18/03/26.
//

import Foundation

final class SleepScoreEngine {
    
    static func calculateScore(for metric: SleepMetricType) -> Double {
        let weeklyData = MetricDataProvider.weeklyData(for: metric)
        guard !weeklyData.isEmpty else { return 0 }
        
        let rawValues = weeklyData.map { $0.value.raw }
        let averageRaw = rawValues.reduce(0, +) / Double(rawValues.count)
        
        switch metric {
        case .duration:
            return min(100, (averageRaw / 8.0) * 100)
            
        case .efficiency:
            return averageRaw
            
        case .architecture:
            let avgDeep = SleepArchitectureDataProvider.getAverageSleepPercentage(for: .deep)
            return min(100, (avgDeep / 20.0) * 100)
            
        case .consistency:
            let scaleOfTen = SleepConsistency.consistencyScore()
            return scaleOfTen * 10
            
        case .calmness:
            return averageRaw
            
        case .continuity:
            return averageRaw
        }
    }
}
