//
//  MetricDataProvider .swift
//  WakeWell
//
//  Created by geu on 13/03/26.
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
//architecture
enum SleepStageType: CaseIterable {
    case deep
    case rem
    case light

    var title: String {
        switch self {
        case .deep: return "Deep"
        case .rem: return "REM"
        case .light: return "Light"
        }
    }
}
final class SleepArchitectureDataProvider {

    static func getWeeklyData() -> [DailySleepArchitecture] {
        return [
            DailySleepArchitecture(day: "Mon", deep: 20, rem: 25, light: 55),
            DailySleepArchitecture(day: "Tue", deep: 18, rem: 22, light: 60),
            DailySleepArchitecture(day: "Wed", deep: 22, rem: 24, light: 54),
            DailySleepArchitecture(day: "Thu", deep: 19, rem: 26, light: 55),
            DailySleepArchitecture(day: "Fri", deep: 21, rem: 23, light: 56),
            DailySleepArchitecture(day: "Sat", deep: 17, rem: 27, light: 56),
            DailySleepArchitecture(day: "Sun", deep: 20, rem: 25, light: 55)
        ]
    }

    static func getAverageSleepPercentage(for stage: SleepStageType) -> Double {

        let data = getWeeklyData()
        guard !data.isEmpty else { return 0 }

        let total = data.reduce(0.0) { result, day in
            switch stage {
            case .deep:  return result + day.deep
            case .rem:   return result + day.rem
            case .light: return result + day.light
            }
        }

        return total / Double(data.count)
    }

    static func getAllAverages() -> (deep: Double, rem: Double, light: Double) {

        let data = getWeeklyData()
        guard !data.isEmpty else { return (0, 0, 0) }

        var deepTotal = 0.0
        var remTotal = 0.0
        var lightTotal = 0.0

        for day in data {
            deepTotal += day.deep
            remTotal += day.rem
            lightTotal += day.light
        }

        let count = Double(data.count)

        return (
            deepTotal / count,
            remTotal / count,
            lightTotal / count
        )
    }
}
class SleepCalmnessAnalyzer {

    static func analyzeWeek() -> CalmnessStats {

        let movement = [12.0, 9.0, 7.0, 6.0, 8.0, 10.0, 11.0]
        let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        let restlessness = [40.0, 35.0, 50.0, 32.0, 30.0, 28.0, 34.0]

        let avgMovement = movement.reduce(0,+) / Double(movement.count)

        let avgRestlessness = restlessness.reduce(0,+) / Double(restlessness.count)

        return CalmnessStats(
            movementPerNight: movement,
            restlessnessScoreTrend: restlessness,
            days: days,
            averageMovement: avgMovement,
            averageRestlessnessScore: avgRestlessness
        )
    }
}

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

        let avgBedtime = data.map { $0.bedtime }.reduce(0,+) / Double(data.count)
        let avgWakeTime = data.map { $0.wakeTime }.reduce(0,+) / Double(data.count)

        let bedtimeVariation = data.map { abs($0.bedtime - avgBedtime) }.reduce(0,+) / Double(data.count)
        let wakeVariation = data.map { abs($0.wakeTime - avgWakeTime) }.reduce(0,+) / Double(data.count)

        let totalVariation = (bedtimeVariation + wakeVariation) / 2

        let score = max(0, 10 - (totalVariation * 5))

        return score
    }

    static func consistencyInsight() -> String {

        let score = consistencyScore()
        switch score {
        case 8...10:
            return "Excellent"
        case 6..<8:
            return "Good"
        case 4..<6:
            return "Average"
        default:
            return "Poor"
        }
    }
}
//Continuity Analyser
class SleepContinuityAnalyzer {

    static func analyzeWeek() -> ContinuityStats {
        let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        let awakenings = [3,2,4,1,2,3,2]
        let longestBlock = 5.4
        let avg = Double(awakenings.reduce(0,+)) / Double(awakenings.count)
        return ContinuityStats(
            days: days,
            awakeningsPerNight: awakenings,
            longestSleepBlock: longestBlock,
            averageAwakenings: avg
        )
    }
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
