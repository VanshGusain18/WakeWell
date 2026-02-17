//
//  EfficiencyMetric.swift
//  WakeWell
//
//  Created by geu on 14/02/26.
//

import Foundation
struct EfficiencyMetric {

    let day: String
    let timeInBed: Double
    let sleepStart: Double
    var efficiencyPercentage: Double {
            guard timeInBed > 0 else { return 0 }
            return (sleepStart / timeInBed) * 100
        }
}

struct EfficiencyDataProvider {

    static func weeklyData() -> [EfficiencyMetric] {
        return [
            EfficiencyMetric(day: "Mon", timeInBed: 8.0, sleepStart: 7.2),
            EfficiencyMetric(day: "Tue", timeInBed: 7.5, sleepStart: 6.8),
            EfficiencyMetric(day: "Wed", timeInBed: 8.3, sleepStart: 7.9),
            EfficiencyMetric(day: "Thu", timeInBed: 7.8, sleepStart: 7.1),
            EfficiencyMetric(day: "Fri", timeInBed: 8.5, sleepStart: 8.0),
            EfficiencyMetric(day: "Sat", timeInBed: 9.0, sleepStart: 8.4),
            EfficiencyMetric(day: "Sun", timeInBed: 7.2, sleepStart: 6.5)
        ]
    }
}
