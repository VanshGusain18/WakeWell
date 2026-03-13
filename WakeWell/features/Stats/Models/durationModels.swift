//
//  durationModels.swift
//  WakeWell
//
//  Created by geu on 12/03/26.
//

import Foundation

struct SleepDurationData {
    
    let day: String
    let hoursSlept: Double
}

class SleepDurationModel {
    
    static func getWeeklySleepDuration() -> [SleepDurationData] {
        
        return [
            SleepDurationData(day: "Mon", hoursSlept: 7.5),
            SleepDurationData(day: "Tue", hoursSlept: 6.8),
            SleepDurationData(day: "Wed", hoursSlept: 7.2),
            SleepDurationData(day: "Thu", hoursSlept: 8.0),
            SleepDurationData(day: "Fri", hoursSlept: 6.5),
            SleepDurationData(day: "Sat", hoursSlept: 8.3),
            SleepDurationData(day: "Sun", hoursSlept: 7.9)
        ]
    }
    
    static func getAverageSleepDuration() -> Double {
        
        let data = getWeeklySleepDuration()
        
        let total = data.reduce(0) { $0 + $1.hoursSlept }
        
        return total / Double(data.count)
    }
}
