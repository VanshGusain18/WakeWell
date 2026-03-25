//
//  statsTimeRange.swift
//  WakeWell
//
//  Created by geu on 24/03/26.
//
import Foundation

enum StatsTimeRange: Int, CaseIterable {
    case week  = 0
    case month = 1
    case year  = 2

    var title: String {
        switch self {
        case .week:  return "Week"
        case .month: return "Month"
        case .year:  return "Year"
        }
    }

    var xAxisLabels: [String] {
        switch self {
        case .week:
            return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        case .month:
            return ["W1", "W2", "W3", "W4"]
        case .year:
            return ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        }
    }

    var dataPointCount: Int { xAxisLabels.count }
}
