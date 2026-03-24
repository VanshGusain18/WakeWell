//
//  DurationViewModel.swift
//  WakeWell
//
//  Created by geu on 19/03/26.
//

import Foundation
import UIKit
//calmness data
class SleepCalmnessAnalyzer {
    
    // MARK: - Weekly Raw Data
    static func getWeeklyCalmness() -> [CalmnessData] {
        return [
            CalmnessData(day: "Mon", movementScore: 12.0, restlessnessScore: 20.0),
            CalmnessData(day: "Tue", movementScore: 9.0,  restlessnessScore: 15.0),
            CalmnessData(day: "Wed", movementScore: 7.0,  restlessnessScore: 10.0),
            CalmnessData(day: "Thu", movementScore: 6.0,  restlessnessScore: 12.0),
            CalmnessData(day: "Fri", movementScore: 8.0,  restlessnessScore: 18.0),
            CalmnessData(day: "Sat", movementScore: 10.0, restlessnessScore: 14.0),
            CalmnessData(day: "Sun", movementScore: 7.0,  restlessnessScore: 11.0)
        ]
    }
    
    // MARK: - Calmness Score Logic
    static func calculateCalmnessScore(movement: Double, restlessness: Double) -> Double {
        // Lower movement & restlessness = higher score
        let rawScore = 100 - (0.5 * restlessness + 0.3 * movement)
        return max(0, min(100, rawScore))
    }
    
    // MARK: - Average Score
    static func getAverageScore() -> Double {
        let data = getWeeklyCalmness()
        let totalScore = data.reduce(0) { $0 + calculateCalmnessScore(movement: $1.movementScore, restlessness: $1.restlessnessScore) }
        return totalScore / Double(data.count)
    }
    
    // MARK: - 📈 Trend Chart Data (Score)
    static func trendChartData(from data: [CalmnessData]) -> (
        title: String,
        dataSets: [LineChartDataSetModel],
        xAxisLabels: [String]
    ) {
        let labels = data.map { $0.day }
        let entries = data.enumerated().map { index, item in
            LineChartDataEntryModel(
                xIndex: Double(index),
                value: calculateCalmnessScore(movement: item.movementScore, restlessness: item.restlessnessScore)
            )
        }
        
        let dataSet = LineChartDataSetModel(
            label: "Calmness Score",
            values: entries,
            color: .systemTeal
        )
        
        return (
            title: "Calmness Score Trend",
            dataSets: [dataSet],
            xAxisLabels: labels
        )
    }
    
    // MARK: - 📊 Fragmentation / Movement Chart Data
    static func movementChartData(from data: [CalmnessData]) -> (
        title: String,
        dataSets: [BarChartDataSetModel],
        xAxisLabels: [String]
    ) {
        let labels = data.map { $0.day }
        
        let movementEntries = data.enumerated().map { index, item in
            BarChartDataEntryModel(
                xIndex: Double(index),
                value: item.movementScore
            )
        }
        
        let restlessnessEntries = data.enumerated().map { index, item in
            BarChartDataEntryModel(
                xIndex: Double(index),
                value: item.restlessnessScore
            )
        }
        
        let dataSets = [
            BarChartDataSetModel(label: "Movement", color: .systemBlue, values: movementEntries),
            BarChartDataSetModel(label: "Restlessness", color: .systemOrange, values: restlessnessEntries)
        ]
        
        return (
            title: "Sleep Movement & Restlessness",
            dataSets: dataSets,
            xAxisLabels: labels
        )
    }
    
    // MARK: - Info Section
    static func calmnessInfo() -> String {
        return """
        Sleep calmness reflects how restful your sleep is during the night. 
        Lower movement and fewer restlessness events indicate more restorative sleep.

        Improving calmness can boost overall sleep quality, cognitive performance, and recovery.
        """
    }
}

