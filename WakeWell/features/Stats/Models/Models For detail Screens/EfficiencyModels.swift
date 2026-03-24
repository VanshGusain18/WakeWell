//
//  EfficiencyMetric.swift
//  WakeWell
//
//  Created by geu on 14/02/26.
//

import Foundation

struct EfficiencyData {
    let day: String
    let timeInBed: Double
    let timeAsleep: Double

    var efficiency: Double {
        guard timeInBed > 0 else { return 0 }
        return (timeAsleep / timeInBed) * 100
    }

    var score: Double {
        return EfficiencyModel.calculateEfficiencyScore(
            timeInBed: timeInBed,
            timeAsleep: timeAsleep
        )
    }
}
