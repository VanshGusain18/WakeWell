//
//  SleepStatsMapper.swift
//  WakeWell
//
//  Created by geu on 13/02/26.
//

import Foundation
struct SleepStatsMapper {
    
    static func mapToMetrics(from stats: SleepStats) -> [SleepMetric] {
        
        return [
            SleepMetric(type: .duration,
                        displayValue: "\(stats.duration) h"),
            
            SleepMetric(type: .efficiency,
                        displayValue: "\(stats.efficiency)%"),
            
            SleepMetric(type: .architecture,
                        displayValue: "\(stats.architecture)%"),
            
            SleepMetric(type: .consistency,
                        displayValue: "\(stats.consistency)"),
            
            SleepMetric(type: .calmness,
                        displayValue: "\(stats.calmness)"),
            
            SleepMetric(type: .continuity,
                        displayValue: "\(stats.continuity)")
        ]
    }
}
