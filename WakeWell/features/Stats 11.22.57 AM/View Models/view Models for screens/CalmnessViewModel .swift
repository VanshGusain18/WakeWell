//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//

import Foundation
//calmness data
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
