//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//

import Foundation
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
