//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//

import Foundation
//Efficiency data
class EfficiencyModel {
    
    static func getWeeklyEfficiency() -> [EfficiencyData] {
        
        return [
            EfficiencyData(day: "Mon", timeInBed: 9, timeAsleep: 8),
            EfficiencyData(day: "Tue", timeInBed: 8.5, timeAsleep: 7.5),
            EfficiencyData(day: "Wed", timeInBed: 8, timeAsleep: 7),
            EfficiencyData(day: "Thu", timeInBed: 9, timeAsleep: 8),
            EfficiencyData(day: "Fri", timeInBed: 8, timeAsleep: 7.5),
            EfficiencyData(day: "Sat", timeInBed: 9.5, timeAsleep: 8.5),
            EfficiencyData(day: "Sun", timeInBed: 8.5, timeAsleep: 7.8)
        ]
    }
    static func getAverageEfficiency() -> Double {

        let weeklyData = getWeeklyEfficiency()

        let totalEfficiency = weeklyData.reduce(0) { result, data in
            result + data.efficiency
        }

        return totalEfficiency / Double(weeklyData.count)
    }
    
}
