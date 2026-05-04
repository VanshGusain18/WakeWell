//
//  AlarmViewModel.swift
//  WakeWell
//
//  Owns all alarm business logic: HealthKit queries, notification
//  scheduling, persistence. The view controller only calls into this.
//

import Foundation
import UserNotifications

protocol AlarmViewModelDelegate: AnyObject {
    func alarmDidSave(wakeUpTime: Date, isSmart: Bool)
    func alarmSaveFailed(message: String)
}

final class AlarmViewModel {

    // MARK: - Public state
    var config = AlarmConfiguration()
    weak var delegate: AlarmViewModelDelegate?

    // MARK: - Save alarm
    func saveAlarm() {
        guard config.wakeUpEnabled else {
            delegate?.alarmSaveFailed(message: "Enable the Wake Up toggle to set an alarm.")
            return
        }

        AlarmManager.shared.setAlarm(AlarmModel(time: config.wakeUpTime))
        NotificationCenter.default.post(name: .alarmTimeDidChange, object: nil)
        delegate?.alarmDidSave(wakeUpTime: config.wakeUpTime, isSmart: true)
    }

    // MARK: - Permissions
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .criticalAlert]
        ) { _, error in
            if let error { print("Notification permission error: \(error)") }
        }
    }

}
