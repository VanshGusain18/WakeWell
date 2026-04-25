import Foundation
import UserNotifications

final class AlarmManager {

    static let shared = AlarmManager()

    private init() {}

    private var currentAlarm: AlarmModel?

    private let alarmKey = "wakewell_alarm_time"

    // MARK: - Public API

    func setAlarm(_ alarm: AlarmModel) {
        currentAlarm = alarm

        guard let time = alarm.time else {
            print("⛔ Cannot set alarm without a time")
            return
        }

        UserDefaults.standard.set(time.timeIntervalSince1970, forKey: alarmKey)
        NotificationManager.shared.cancelAllScheduledAlarms()
        NotificationManager.shared.scheduleSmartAlarmWindow(baseTime: time)
        SleepSessionManager.shared.startSession(alarmTime: time)
        SmartAlarmEngine.shared.beginMonitoring()

        print("⏰ Alarm set for:", time)
    }

    func getAlarm() -> AlarmModel? {
        currentAlarm
    }

    func getWakeTime() -> Date? {
        currentAlarm?.time
    }

    // MARK: - Dev Helper

    func setTestAlarm() {
        let testTime = Date().addingTimeInterval(5 * 60)
        currentAlarm = AlarmModel(time: testTime)
        print("🧪 Test alarm set for:", testTime)
    }

    func loadSavedAlarm() {
        let timestamp = UserDefaults.standard.double(forKey: alarmKey)

        guard timestamp > 0 else { return }

        let date = Date(timeIntervalSince1970: timestamp)
        currentAlarm = AlarmModel(time: date)

        print("📦 Loaded saved alarm:", date)
    }
}

final class NotificationManager: NSObject {

    static let shared = NotificationManager()

    private override init() {
        super.init()
    }

    private let notificationCenter = UNUserNotificationCenter.current()
    private let scheduledPrefix = "wakewell.smartAlarm.scheduled"
    private let immediatePrefix = "wakewell.smartAlarm.immediate"
    private let notificationCategory = "WAKEWELL_ALARM"
    private let customSoundName = "alarm_chime.caf"
    private let wakeWindowMinutes = 30
    private let intervalMinutes = 5

    // MARK: - Public

    func configure() {
        notificationCenter.delegate = self
        registerNotificationCategory()
    }

    func requestAuthorizationIfNeeded(completion: ((Bool) -> Void)? = nil) {
        notificationCenter.getNotificationSettings { [weak self] settings in
            guard let self else {
                completion?(false)
                return
            }

            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                self.registerNotificationCategory()
                completion?(true)
            case .notDetermined:
                self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error {
                        print("❌ Notification permission error:", error.localizedDescription)
                    } else {
                        print("🔔 Notification permission granted:", granted)
                    }

                    if granted {
                        self.registerNotificationCategory()
                    }

                    completion?(granted)
                }
            case .denied:
                print("⛔ Notification permission denied")
                completion?(false)
            @unknown default:
                completion?(false)
            }
        }
    }

    func scheduleSmartAlarmWindow(baseTime: Date) {
        requestAuthorizationIfNeeded { [weak self] granted in
            guard let self, granted else {
                print("⛔ Smart alarm scheduling skipped: notification permission unavailable")
                return
            }

            let normalizedBaseTime = self.normalizedBaseTime(from: baseTime)
            let windowStart = normalizedBaseTime.addingTimeInterval(TimeInterval(-self.wakeWindowMinutes * 60))
            let fireDates = self.notificationDates(from: windowStart, to: normalizedBaseTime)

            guard !fireDates.isEmpty else {
                print("⛔ No valid smart alarm notifications to schedule")
                return
            }

            self.registerNotificationCategory()

            for (index, fireDate) in fireDates.enumerated() {
                let identifier = "\(self.scheduledPrefix).\(Int(normalizedBaseTime.timeIntervalSince1970)).\(index)"
                let content = self.makeAlarmContent(
                    title: "Rise & Shine",
                    subtitle: "Smart wake window",
                    body: "WakeWell is ready to wake you gently.",
                    fireDate: fireDate,
                    isImmediate: false
                )

                let components = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second],
                    from: fireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                self.notificationCenter.add(request) { error in
                    if let error {
                        print("❌ Failed to schedule alarm \(identifier):", error.localizedDescription)
                    }
                }
            }

            let formattedTimes = fireDates.map { self.timestampFormatter.string(from: $0) }.joined(separator: ", ")
            print("✅ Smart alarm window scheduled:", formattedTimes)
        }
    }

    func cancelAllScheduledAlarms(completion: (() -> Void)? = nil) {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            guard let self else {
                completion?()
                return
            }

            let pendingIdentifiers = requests
                .map(\.identifier)
                .filter { self.isWakeWellAlarmIdentifier($0) }

            if !pendingIdentifiers.isEmpty {
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: pendingIdentifiers)
            }

            self.notificationCenter.getDeliveredNotifications { notifications in
                let deliveredIdentifiers = notifications
                    .map { $0.request.identifier }
                    .filter { self.isWakeWellAlarmIdentifier($0) }

                if !deliveredIdentifiers.isEmpty {
                    self.notificationCenter.removeDeliveredNotifications(withIdentifiers: deliveredIdentifiers)
                }

                print("🗑️ Cancelled scheduled alarms:", pendingIdentifiers.count + deliveredIdentifiers.count)
                completion?()
            }
        }
    }

    func triggerImmediateAlarm() {
        cancelAllScheduledAlarms { [weak self] in
            guard let self else { return }

            self.requestAuthorizationIfNeeded { granted in
                guard granted else {
                    print("⛔ Immediate alarm skipped: notification permission unavailable")
                    return
                }

                let fireDate = Date().addingTimeInterval(1)
                let identifier = "\(self.immediatePrefix).\(UUID().uuidString)"
                let content = self.makeAlarmContent(
                    title: "Wake Now",
                    subtitle: "Smart wake trigger",
                    body: "WakeWell detected the right wake moment.",
                    fireDate: fireDate,
                    isImmediate: true
                )

                let components = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second],
                    from: fireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                self.notificationCenter.add(request) { error in
                    if let error {
                        print("❌ Failed to trigger immediate alarm:", error.localizedDescription)
                    } else {
                        print("🚨 Immediate alarm triggered for:", self.timestampFormatter.string(from: fireDate))
                    }
                }
            }
        }
    }

    // MARK: - Private

    private var timestampFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }

    private func normalizedBaseTime(from baseTime: Date) -> Date {
        if baseTime > Date() {
            return baseTime
        }

        return Calendar.current.date(byAdding: .day, value: 1, to: baseTime) ?? baseTime
    }

    private func notificationDates(from windowStart: Date, to baseTime: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = windowStart

        while currentDate <= baseTime {
            if currentDate > Date().addingTimeInterval(1) {
                dates.append(currentDate)
            }

            currentDate = Calendar.current.date(byAdding: .minute, value: intervalMinutes, to: currentDate) ?? baseTime.addingTimeInterval(1)
        }

        if dates.isEmpty && baseTime > Date() {
            dates.append(baseTime)
        }

        return dates
    }

    private func makeAlarmContent(
        title: String,
        subtitle: String,
        body: String,
        fireDate: Date,
        isImmediate: Bool
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = alarmSound()
        content.categoryIdentifier = notificationCategory

        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
        }

        content.userInfo = [
            "wakeTime": ISO8601DateFormatter().string(from: fireDate),
            "isImmediate": isImmediate
        ]

        return content
    }

    private func alarmSound() -> UNNotificationSound {
        if Bundle.main.url(forResource: "alarm_chime", withExtension: "caf") != nil {
            return UNNotificationSound(named: UNNotificationSoundName(customSoundName))
        }

        return .default
    }

    private func registerNotificationCategory() {
        let stopAction = UNNotificationAction(
            identifier: "STOP_ALARM",
            title: "Stop Alarm",
            options: [.foreground]
        )

        let startAction = UNNotificationAction(
            identifier: "START_RITUAL",
            title: "Start Ritual",
            options: [.foreground]
        )

        let category = UNNotificationCategory(
            identifier: notificationCategory,
            actions: [stopAction, startAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "Alarm",
            options: [.customDismissAction, .allowAnnouncement]
        )

        notificationCenter.setNotificationCategories([category])
    }

    private func isWakeWellAlarmIdentifier(_ identifier: String) -> Bool {
        identifier.hasPrefix(scheduledPrefix) || identifier.hasPrefix(immediatePrefix)
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }
}
