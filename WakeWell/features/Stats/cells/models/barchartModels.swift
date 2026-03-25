//
//  barchartModels.swift
//  WakeWell
//
//  Created by geu on 23/03/26.
//

import Foundation
import UIKit

struct BarChartDataEntryModel {
    let xIndex: Double
    let value: Double
}

struct BarChartDataSetModel {
    let label: String
    let values: [BarChartDataEntryModel]
}
