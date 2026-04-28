//
//  AlarmViewModel.swift
//  WakeWell
//
//  Owns all alarm business logic: HealthKit queries, notification
//  scheduling, persistence. The view controller only calls into this.
//

import Foundation
import UserNotifications
import HealthKit

protocol AlarmViewModelDelegate: AnyObject {
    func alarmDidSave(wakeUpTime: Date, isSmart: Bool)
    func alarmSaveFailed(message: String)
}

final class AlarmViewModel {

    // MARK: - Public state
    var config = AlarmConfiguration()
    weak var delegate: AlarmViewModelDelegate?

    // MARK: - Private
    private let healthStore = HKHealthStore()

    // MARK: - Save alarm
    func saveAlarm() {
        guard config.wakeUpEnabled else {
            delegate?.alarmSaveFailed(message: "Enable the Wake Up toggle to set an alarm.")
            return
        }

        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["wakewell.alarm"]
        )

        UserDefaults.standard.set(config.wakeUpTime, forKey: "wakewell.savedAlarmTime")
        NotificationCenter.default.post(name: .alarmTimeDidChange, object: nil)

        requestHealthKitPermission { [weak self] granted in
            guard let self else { return }
            if granted {
                self.scheduleSmartAlarm()
            } else {
                self.scheduleNotification(at: self.config.wakeUpTime, isSmart: false)
                self.delegate?.alarmDidSave(wakeUpTime: self.config.wakeUpTime, isSmart: false)
            }
        }
    }

    // MARK: - Permissions
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .criticalAlert]
        ) { _, error in
            if let error { print("Notification permission error: \(error)") }
        }
    }

    // MARK: - HealthKit
    private func requestHealthKitPermission(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable(),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false); return
        }
        healthStore.requestAuthorization(toShare: nil, read: [sleepType]) { success, _ in
            completion(success)
        }
    }

    // MARK: - Smart alarm scheduling
    private func scheduleSmartAlarm() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            scheduleNotification(at: config.wakeUpTime, isSmart: false)
            delegate?.alarmDidSave(wakeUpTime: config.wakeUpTime, isSmart: false)
            return
        }

        let windowStart = Calendar.current.date(
            byAdding: .minute, value: -config.smartWindowMinutes, to: config.wakeUpTime
        ) ?? config.wakeUpTime

        let predicate = HKQuery.predicateForSamples(
            withStart: windowStart, end: config.wakeUpTime, options: .strictEndDate
        )
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: sleepType, predicate: predicate,
            limit: HKObjectQueryNoLimit, sortDescriptors: [sort]
        ) { [weak self] _, samples, error in
            guard let self else { return }
            if let error {
                print("HealthKit sleep query error: \(error)")
                self.scheduleNotification(at: self.config.wakeUpTime, isSmart: false)
                self.delegate?.alarmDidSave(wakeUpTime: self.config.wakeUpTime, isSmart: false)
                return
            }
            let sleepSamples = (samples as? [HKCategorySample]) ?? []
            let lightMoment = self.findLightSleepMoment(
                in: sleepSamples, windowStart: windowStart, windowEnd: self.config.wakeUpTime
            )
            let fireDate = lightMoment ?? self.config.wakeUpTime
            self.scheduleNotification(at: fireDate, isSmart: lightMoment != nil)
            self.delegate?.alarmDidSave(wakeUpTime: fireDate, isSmart: lightMoment != nil)
        }
        healthStore.execute(query)
    }

    private func findLightSleepMoment(in samples: [HKCategorySample],
                                      windowStart: Date, windowEnd: Date) -> Date? {
        let lightStages: Set<Int> = [0, 2, 3] // inBed, awake, asleepCore
        return samples
            .filter { $0.startDate >= windowStart && $0.startDate <= windowEnd }
            .sorted { $0.startDate < $1.startDate }
            .first { lightStages.contains($0.value) }
            .map(\.startDate)
    }

    // MARK: - Notification scheduling
    private func scheduleNotification(at fireDate: Date, isSmart: Bool) {
        registerNotificationCategory()

        let content = UNMutableNotificationContent()
        content.title             = "Rise & Shine ☀️"
        content.subtitle          = isSmart ? "Smart alarm — light sleep detected" : "Your alarm"
        content.body              = "Tap to start your morning ritual."
        content.sound             = alarmSound()
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "WAKEWELL_ALARM"
        content.userInfo = [
            "wakeTime": ISO8601DateFormatter().string(from: fireDate),
            "isSmart": isSmart
        ]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second], from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "wakewell.alarm", content: content, trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("Failed to schedule alarm: \(error)") }
            else { print("✅ Alarm scheduled for \(fireDate)") }
        }
    }

    private func alarmSound() -> UNNotificationSound {
        if Bundle.main.url(forResource: "alarm_chime", withExtension: "caf") != nil {
            return UNNotificationSound(named: UNNotificationSoundName("alarm_chime.caf"))
        }
        return .defaultCritical
    }

    private func registerNotificationCategory() {
        let stop  = UNNotificationAction(
            identifier: "STOP_ALARM", title: "Stop Alarm", options: [.foreground]
        )
        let start = UNNotificationAction(
            identifier: "START_RITUAL", title: "▶ Start Morning Ritual", options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: "WAKEWELL_ALARM", actions: [stop, start],
            intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "Alarm",
            options: [.customDismissAction, .allowAnnouncement]
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
