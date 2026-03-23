//
//  continuityModels.swift
//  WakeWell
//
//  Created by geu on 10/03/26.
//

import Foundation


struct ContinuityData {
    let day: String
    let awakenings: Int
    let totalAwakeTime: Double

    var score: Double {
        return SleepContinuityAnalyzer.calculateContinuityScore(
            awakenings: awakenings,
            awakeTime: totalAwakeTime
        )
    }
}

// MARK: - Weekly Stats (optional container)
struct ContinuityStats {
    let data: [ContinuityData]
    let averageScore: Double
}
