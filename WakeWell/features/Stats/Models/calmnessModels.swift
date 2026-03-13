//
//  calmnessModels.swift
//  WakeWell
//
//  Created by geu on 10/03/26.
//

import Foundation

struct CalmnessStats {

    let movementPerNight: [Double]
    let restlessnessScoreTrend: [Double]
    let days: [String]

    let averageMovement: Double
    let averageRestlessnessScore: Double
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


    static func calmnessInsight() -> String {

        let stats = analyzeWeek()

        let avgMovement = stats.averageMovement
        let avgRestless = stats.averageRestlessnessScore

        let movementScore = avgMovement / 15
        let restlessScore = avgRestless / 100

        let combinedScore = (movementScore + restlessScore) / 2

        switch combinedScore {

        case 0..<0.25:
            return "Very Calm"

        case 0.25..<0.5:
            return "Calm"

        case 0.5..<0.75:
            return "Restless"

        default:
            return "Very Restless"
        }
    }
}
