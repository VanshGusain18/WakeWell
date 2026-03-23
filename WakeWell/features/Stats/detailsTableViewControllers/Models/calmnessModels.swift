//
//  calmnessModels.swift
//  WakeWell
//
//  Created by geu on 10/03/26.
//

import Foundation
import UIKit

// MARK: - Calmness Data Model
struct CalmnessData {
    let day: String
    let movementScore: Double      // e.g., movement per night
    let restlessnessScore: Double  // computed restlessness score
    
    // Optional: overall score (normalized 0-100)
    var score: Double {
        return max(0, min(100, 100 - restlessnessScore)) // simple inversion
    }
}

