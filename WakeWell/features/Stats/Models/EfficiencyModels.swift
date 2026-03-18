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
        return (timeAsleep / timeInBed) * 100
    }
}
