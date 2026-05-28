//
//  continuityModels.swift
//  SetSail
//
//  Created by geu on 10/03/26.
//

import Foundation

struct ContinuityData {
    let day: String
    let awakenings: Int
    let totalAwakeTime: Double

    var score: Double {
        SleepScoreCalculator.continuityScore(awakenings: awakenings, waso: totalAwakeTime)
    }
}
