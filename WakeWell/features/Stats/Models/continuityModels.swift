//
//  continuityModels.swift
//  WakeWell
//
//  Created by geu on 10/03/26.
//

import Foundation

struct ContinuityStats {

    let days: [String]
    let awakeningsPerNight: [Int]
    let longestSleepBlock: Double
    let averageAwakenings: Double
}

//Continuity Analyser
class SleepContinuityAnalyzer {

    static func analyzeWeek() -> ContinuityStats {

        // Sample data for now
        let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        let awakenings = [3,2,4,1,2,3,2]

        // Longest uninterrupted sleep block
        let longestBlock = 5.4 //hrs

        // Average awakenings
        let avg = Double(awakenings.reduce(0,+)) / Double(awakenings.count)

        return ContinuityStats(
            days: days,
            awakeningsPerNight: awakenings,
            longestSleepBlock: longestBlock,
            averageAwakenings: avg
        )
    }
}
