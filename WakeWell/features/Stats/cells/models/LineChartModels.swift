//
//  LineChartModels.swift
//  SetSail
//
//  Created by geu on 23/03/26.
//

import UIKit

struct LineChartDataEntryModel {
    let xIndex: Double
    let value: Double
}

struct LineChartDataSetModel {
    let label: String
    let values: [LineChartDataEntryModel]
}
