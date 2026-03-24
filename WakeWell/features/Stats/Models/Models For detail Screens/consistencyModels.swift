//
//  consistencyModels.swift
//  WakeWell
//
//  Created by geu on 12/03/26.
//

import Foundation

struct SleepConsistencyData {

    let day: String
    let bedtime: Double
    let wakeTime: Double
    var score: Double {
        return SleepConsistencyAnalyzer.calculateConsistencyScore(bedtime: bedtime, wakeTime: wakeTime)
    }
}


