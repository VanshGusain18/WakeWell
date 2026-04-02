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
            let data = SleepDurationModel.getWeeklySleepDuration()
            return data.map { MetricData(day: $0.day, value: MetricValue(raw: $0.hoursSlept)) }
            
        case .efficiency:
            let data = EfficiencyModel.getWeeklyEfficiency()
            return data.map { MetricData(day: $0.day, value: MetricValue(raw: $0.efficiency)) }
            
        case .architecture:
            let data = SleepArchitectureDataProvider.getWeeklyData()
            return data.map { day in
                let qualityScore = day.deep + day.rem + (day.light * 0.2)
                return MetricData(day: day.day, value: MetricValue(raw: qualityScore))
            }
            
        case .continuity:
            let stats = SleepContinuityAnalyzer.analyzeWeek()
            return stats.days.enumerated().map { index, day in
                let value = max(0, 100 - (Double(stats.awakeningsPerNight[index]) * 10))
                return MetricData(day: day, value: MetricValue(raw: value))
            }
            
        case .calmness:
            let stats = SleepCalmnessAnalyzer.analyzeWeek()
            return stats.days.enumerated().map { index, day in
                let restlessness = stats.restlessnessScoreTrend[index]
                let movement = stats.movementPerNight[index]
                let calmnessScore = 100 - ((restlessness + (movement * 3)) / 2)
                return MetricData(day: day, value: MetricValue(raw: calmnessScore))
            }
            
        case .consistency:
            let data = SleepConsistency.weeklyData()
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
            let avgDeep = SleepArchitectureDataProvider.getAverageSleepPercentage(for: .deep)
            return min(100, (avgDeep / 20.0) * 100)
            
        case .consistency:
            let sleepConsistency = SleepConsistency.consistencyScore()
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
