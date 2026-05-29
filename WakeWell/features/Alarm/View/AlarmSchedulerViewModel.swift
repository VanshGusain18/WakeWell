//
//  AlarmSchedulerViewModel.swift   ← renamed from AlarmViewModel to avoid
//  SetSail                           conflict with Home/ViewModel/AlarmViewModel.swift
//
//  Owns all alarm business logic: HealthKit queries, notification scheduling, persistence.
//

import Foundation
import UserNotifications

protocol AlarmSchedulerViewModelDelegate: AnyObject {
    func alarmDidSave(wakeUpTime: Date, isSmart: Bool)
    func alarmSaveFailed(message: String)
}

final class AlarmSchedulerViewModel {

    // MARK: - Public state
    var config = AlarmConfiguration()
    weak var delegate: AlarmSchedulerViewModelDelegate?

    // MARK: - Save alarm
    func saveAlarm() {
        guard config.wakeUpEnabled else {
            delegate?.alarmSaveFailed(message: "Enable the Wake Up toggle to set an alarm.")
            return
        }

        AlarmManager.shared.setAlarm(
            AlarmModel(time: config.wakeUpTime),
            smartWindowMinutes: config.smartWindowMinutes
        )
        NotificationCenter.default.post(name: .alarmTimeDidChange, object: nil)
        delegate?.alarmDidSave(wakeUpTime: config.wakeUpTime, isSmart: true)
    }

    // MARK: - Permissions
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .criticalAlert]
        ) { _, _ in }
    }

}
