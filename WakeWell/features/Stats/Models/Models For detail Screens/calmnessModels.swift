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
    let movementScore: Double
    let restlessnessScore: Double
    
    var score: Double {
        return max(0, min(100, 100 - restlessnessScore)) 
    }
}

