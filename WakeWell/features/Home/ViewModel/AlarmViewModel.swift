//
//  AlarmViewModel.swift
//  WakeWell
//
//  Created by geu on 13/02/26.
//
import Foundation

struct AlarmViewModel {

    let title: String
    let timeText: String
    let subtitleText: String

    init(model: AlarmModel) {

        if let time = model.time {
            title = "Your alarm will ring at"
            timeText = Self.format(time: time)
            subtitleText = "Tap to edit"
        } else {
            title = "No alarm set"
            timeText = "--:--"
            subtitleText = "Tap to set alarm"
        }
    }

    private static func format(time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}
