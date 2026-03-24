//
//  ArchitectureModels.swift
//  WakeWell
//
//  Created by geu on 12/03/26.
//
import Foundation

struct SleepArchitectureData {
    let day: String
    let deep: Double
    let rem: Double
    let light: Double
    
    // Convenience: total sum = 100
    var total: Double { deep + rem + light }
    
    var score: Double {
        let deepScore = 100 - min(abs(deep - 20) * 4, 100)
        let remScore = 100 - min(abs(rem - 22.5) * 4, 100)
        let lightScore = 100 - min(abs(light - 55) * 2, 100)
        return max(0, min(100, (deepScore + remScore + lightScore) / 3))
    }
}
