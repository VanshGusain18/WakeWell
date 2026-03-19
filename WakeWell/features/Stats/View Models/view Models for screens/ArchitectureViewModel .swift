//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//

import Foundation
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
