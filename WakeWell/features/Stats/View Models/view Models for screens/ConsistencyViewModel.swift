//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//

import Foundation
//consistency data
extension SleepConsistency {
    
    static func weeklyData() -> [SleepConsistency] {
        
        return [
            SleepConsistency(day: "Mon", bedtime: 23.0, wakeTime: 7.0),
            SleepConsistency(day: "Tue", bedtime: 23.5, wakeTime: 7.2),
            SleepConsistency(day: "Wed", bedtime: 24.0, wakeTime: 7.5),
            SleepConsistency(day: "Thu", bedtime: 23.2, wakeTime: 7.1),
            SleepConsistency(day: "Fri", bedtime: 23.8, wakeTime: 7.4),
            SleepConsistency(day: "Sat", bedtime: 24.0, wakeTime: 8.0),
            SleepConsistency(day: "Sun", bedtime: 23.3, wakeTime: 7.3)
        ]
    }
    
    static func consistencyScore() -> Double {
        
        let data = weeklyData()
        guard !data.isEmpty else { return 0 }
        
        let avgBedtime = data.map { $0.bedtime }.reduce(0, +) / Double(data.count)
        let avgWakeTime = data.map { $0.wakeTime }.reduce(0, +) / Double(data.count)
        
        let bedtimeVariation = data.map { abs($0.bedtime - avgBedtime) }.reduce(0, +) / Double(data.count)
        let wakeVariation = data.map { abs($0.wakeTime - avgWakeTime) }.reduce(0, +) / Double(data.count)
        
        let totalVariation = (bedtimeVariation + wakeVariation) / 2
        let score = max(0, 100 - (totalVariation * 50))
        return score
    }
}
