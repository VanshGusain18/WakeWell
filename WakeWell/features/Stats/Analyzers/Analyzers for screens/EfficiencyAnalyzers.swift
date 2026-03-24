//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//

import Foundation
import UIKit

class EfficiencyModel {

    // MARK: - Weekly Data
    static func getWeeklyEfficiency() -> [EfficiencyData] {

        return [
            EfficiencyData(day: "Mon", timeInBed: 9, timeAsleep: 8),
            EfficiencyData(day: "Tue", timeInBed: 8.5, timeAsleep: 7.5),
            EfficiencyData(day: "Wed", timeInBed: 8, timeAsleep: 7),
            EfficiencyData(day: "Thu", timeInBed: 9, timeAsleep: 8),
            EfficiencyData(day: "Fri", timeInBed: 8, timeAsleep: 7.5),
            EfficiencyData(day: "Sat", timeInBed: 9.5, timeAsleep: 8.5),
            EfficiencyData(day: "Sun", timeInBed: 8.5, timeAsleep: 7.8)
        ]
    }

    // MARK: - Info Text
    static func durationInfo() -> String {
        return """
        Sleep duration refers to the total amount of time you spend asleep during the night.

        Most adults require 7–9 hours of sleep for optimal health, recovery, and cognitive performance.

        Sleeping less than 7 hours may lead to fatigue, reduced focus, and long-term health risks. Sleeping more than 9–10 hours may indicate poor sleep quality or irregular sleep patterns.

        Your goal should be to consistently stay within the 7–9 hour range.
        """
    }

    // MARK: - Average Efficiency
    static func getAverageEfficiency() -> Double {

        let weeklyData = getWeeklyEfficiency()

        let totalEfficiency = weeklyData.reduce(0) { result, data in
            result + data.efficiency
        }

        return totalEfficiency / Double(weeklyData.count)
    }

    // MARK: - Score Calculation
    static func calculateEfficiencyScore(timeInBed: Double, timeAsleep: Double) -> Double {

        guard timeInBed > 0 else { return 0 }

        let efficiency = (timeAsleep / timeInBed) * 100

        switch efficiency {
        case 95...:
            return 100

        case 75..<95:
            return (efficiency - 75) * (100 / 20)

        default:
            return max(0, efficiency - 50)
        }
    }

    // MARK: - 📈 TREND DATA (Line Chart)
    static func trendChartData(from data: [EfficiencyData]) -> (
        title: String,
        dataSets: [LineChartDataSetModel],
        xAxisLabels: [String]
    ) {

        let labels = data.map { $0.day }

        let entries = data.enumerated().map { index, item in
            LineChartDataEntryModel(
                xIndex: Double(index),
                value: item.score
            )
        }

        let dataSet = LineChartDataSetModel(
            label: "Efficiency Score",
            values: entries,
            color: .systemBlue
        )

        return (
            title: "Efficiency Score Trend",
            dataSets: [dataSet],
            xAxisLabels: labels
        )
    }

    // MARK: - 📊 BREAKDOWN DATA (Bar Chart)
    static func breakdownChartData(from data: [EfficiencyData]) -> (
        title: String,
        dataSets: [BarChartDataSetModel],
        xAxisLabels: [String]
    ) {

        let labels = data.map { $0.day }

        let inBedEntries = data.enumerated().map { index, item in
            BarChartDataEntryModel(
                xIndex: Double(index),
                value: item.timeInBed
            )
        }

        let asleepEntries = data.enumerated().map { index, item in
            BarChartDataEntryModel(
                xIndex: Double(index),
                value: item.timeAsleep
            )
        }

        let dataSets = [
            BarChartDataSetModel(
                label: "In Bed",
                color: .systemBlue,
                values: inBedEntries
            ),
            BarChartDataSetModel(
                label: "Asleep",
                color: .systemGreen,
                values: asleepEntries
            )
        ]

        return (
            title: "Time in Bed vs Time Asleep",
            dataSets: dataSets,
            xAxisLabels: labels
        )
    }
}
