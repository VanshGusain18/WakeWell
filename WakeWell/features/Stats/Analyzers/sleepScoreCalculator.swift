//
//  sleepScoreEngine.swift
//  WakeWell
//
//  Created by geu on 18/03/26.
//

import Foundation

final class MetricDataProvider {
    
    static func weeklyData(for metric: SleepMetricType) -> [MetricData] {
        switch metric {
            
        case .duration:
            let data = SleepDurationAnalyzer.getWeeklyDuration()
            return data.map { MetricData(day: $0.day, value: MetricValue(raw: $0.hoursSlept)) }
            
        case .efficiency:
            let data = EfficiencyModel.getWeeklyEfficiency()
            return data.map { MetricData(day: $0.day, value: MetricValue(raw: $0.efficiency)) }
            
        case .architecture:
            let data = SleepArchitectureAnalyzer.getWeeklyArchitecture()
            return data.map { day in
                let qualityScore = day.deep + day.rem + (day.light * 0.2)
                return MetricData(day: day.day, value: MetricValue(raw: qualityScore))
            }
            
        case .continuity:
            let stats = SleepContinuityAnalyzer.getWeeklyContinuity()
            
            return stats.map { data in
                MetricData(
                    day: data.day,
                    value: MetricValue(raw: data.score) 
                )
            }
            
        case .calmness:
            let stats = SleepCalmnessAnalyzer.getWeeklyCalmness()
            
            return stats.map { data in
                let score = SleepCalmnessAnalyzer.calculateCalmnessScore(
                    movement: data.movementScore,
                    restlessness: data.restlessnessScore
                )
                return MetricData(
                    day: data.day,
                    value: MetricValue(raw: score)
                )
            }        case .consistency:
            let data = SleepConsistencyAnalyzer.getWeeklyConsistency()
            let avgBedtime = data.map { $0.bedtime }.reduce(0,+) / Double(data.count)
            let avgWake = data.map { $0.wakeTime }.reduce(0,+) / Double(data.count)
            
            return data.map { day in
                let variation = abs(day.bedtime - avgBedtime) + abs(day.wakeTime - avgWake)
                let dailyScore = max(0, 100 - (variation * 20))
                return MetricData(day: day.day, value: MetricValue(raw: dailyScore))
            }
        
        }
    }
}
//calculates cards scores
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
            let avgDeep = SleepArchitectureAnalyzer.getAverageScore()
            return avgDeep
            
        case .consistency:
            let sleepConsistency = SleepConsistencyAnalyzer.getAverageScore()
            return sleepConsistency
            
        case .calmness:
            return averageRaw
            
        case .continuity:
            return averageRaw
        }
    }
}
//calculates sleep score for a day, will be used when data is present


//struct SleepScoreLogic {
//    static func calculateOverallDailyScore() -> Int {
//        let allMetrics: [SleepMetricType] = [
//            .duration,
//            .efficiency,
//            .architecture,
//            .consistency,
//            .calmness,
//            .continuity
//        ]
//        let scores = allMetrics.map { SleepScoreEngine.calculateScore(for: $0) }
//        
//        let totalSum = scores.reduce(0, +)
//        let average = totalSum / Double(allMetrics.count)
//        
//        return Int(average.rounded())
//    }
//}
