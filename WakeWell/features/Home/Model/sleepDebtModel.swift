//
//  sleepModel.swift
//  WakeWell
//
//  Created by geu on 01/04/26.
//


import Foundation

struct SleepDebtModel {

    let todaySleepDuration: Double?
    let yesterdaySleepDuration: Double?
    let sleepHistory: [SleepDebtModelItem]

}

struct SleepDebtModelItem {

    let sleepDuration: Double
    let date: Date

}
