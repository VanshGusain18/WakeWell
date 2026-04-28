//
//  AlarmModel.swift
//  WakeWell
//
//  Pure data model for a single alarm configuration.
//  No UIKit imports — safe to use in extensions / tests.
//

import Foundation

struct AlarmConfiguration {
    var wakeUpEnabled: Bool = false
    var bedtimeEnabled: Bool = false
    var wakeUpTime: Date = AlarmConfiguration.defaultWakeTime()
    var bedtime: Date = AlarmConfiguration.defaultBedtime()
    var smartWindowMinutes: Int = 30
    var wakeUpSound: SoundSelection = .default
    var bedtimeSound: SoundSelection = .default
    var wakeUpVolume: Float = 0.7
    var bedtimeVolume: Float = 0.7

    static func defaultWakeTime() -> Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = 7; c.minute = 30
        return Calendar.current.date(from: c) ?? Date()
    }

    static func defaultBedtime() -> Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = 22; c.minute = 30
        return Calendar.current.date(from: c) ?? Date()
    }
}

struct SoundSelection: Equatable {
    var sound: String
    var haptic: String

    static let `default` = SoundSelection(sound: "Early Riser (Default)", haptic: "None (Default)")

    var displayText: String { "\(sound)  •  \(haptic)" }
}

enum SmartWindow: String, CaseIterable {
    case fifteen = "15 min"
    case thirty  = "30 min"
    case fortyFive = "45 min"

    var minutes: Int {
        switch self {
        case .fifteen:   return 15
        case .thirty:    return 30
        case .fortyFive: return 45
        }
    }
}

// MARK: - Notification names
extension Notification.Name {
    static let alarmTimeDidChange = Notification.Name("wakewell.alarmTimeDidChange")
}
