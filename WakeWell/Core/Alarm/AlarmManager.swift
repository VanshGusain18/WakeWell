import AVFoundation
import AudioToolbox
import Foundation
import UserNotifications
import UIKit

final class AlarmManager {

    static let shared = AlarmManager()

    private init() {}

    private var currentAlarm: AlarmModel?

    private let alarmKey = "wakewell_alarm_time"
    private let savedAlarmDateKey = "wakewell.savedAlarmTime"
    private let smartWindowMinutesKey = "wakewell.smartWindowMinutes"
    
    // MARK: - Public API

    func setAlarm(_ alarm: AlarmModel, smartWindowMinutes: Int = 30) {
        currentAlarm = alarm

        guard let time = alarm.time else {
            return
        }

        UserDefaults.standard.set(time.timeIntervalSince1970, forKey: alarmKey)
        UserDefaults.standard.set(time, forKey: savedAlarmDateKey)
        UserDefaults.standard.set(smartWindowMinutes, forKey: smartWindowMinutesKey)
        NotificationManager.shared.cancelAllScheduledAlarms()
        NotificationManager.shared.scheduleSmartAlarmWindow(baseTime: time)
        if alarmWindow(for: time).contains(Date()) {
            SleepSessionManager.shared.startSession(alarmTime: time)
        }
        SmartAlarmEngine.shared.beginMonitoring()
        WatchConnectivityReceiver.shared.sendScheduledSession(alarmTime: time, windowStart: alarmWindowStart(for: time), windowEnd: time)

    }

    func getAlarm() -> AlarmModel? {
        currentAlarm
    }

    func getWakeTime() -> Date? {
        currentAlarm?.time
    }

    var smartWindowMinutes: Int {
        let storedValue = UserDefaults.standard.integer(forKey: smartWindowMinutesKey)
        return storedValue > 0 ? storedValue : 30
    }

    func alarmWindowStart(for alarmTime: Date) -> Date {
        alarmTime.addingTimeInterval(-TimeInterval(smartWindowMinutes * 60))
    }

    func alarmWindow(for alarmTime: Date) -> DateInterval {
        DateInterval(start: alarmWindowStart(for: alarmTime), end: alarmTime)
    }

    func loadSavedAlarm() {
        var savedDate: Date?
        if let storedDate = UserDefaults.standard.object(forKey: savedAlarmDateKey) as? Date {
            savedDate = storedDate
        } else {
            let timestamp = UserDefaults.standard.double(forKey: alarmKey)
            savedDate = timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        }

        guard let savedDate else { return }

        let alarmTime = nextAlarmTime(from: savedDate)
        currentAlarm = AlarmModel(time: alarmTime)
        UserDefaults.standard.set(alarmTime.timeIntervalSince1970, forKey: alarmKey)
        UserDefaults.standard.set(alarmTime, forKey: savedAlarmDateKey)

        NotificationManager.shared.scheduleSmartAlarmWindow(baseTime: alarmTime)
        if alarmWindow(for: alarmTime).contains(Date()) {
            SleepSessionManager.shared.startSession(alarmTime: alarmTime)
        }
        SmartAlarmEngine.shared.beginMonitoring()
        WatchConnectivityReceiver.shared.sendScheduledSession(
            alarmTime: alarmTime,
            windowStart: alarmWindowStart(for: alarmTime),
            windowEnd: alarmTime
        )

    }

    private func nextAlarmTime(from savedDate: Date) -> Date {
        if savedDate > Date().addingTimeInterval(1) {
            return savedDate
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: savedDate)
        return calendar.nextDate(
            after: Date(),
            matching: components,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        ) ?? savedDate
    }
}

final class AlarmPresentationManager {
    static let shared = AlarmPresentationManager()

    private var audioPlayer: AVAudioPlayer?
    private var alarmWindow: UIWindow?
    private var isPresenting = false

    private init() {}

    func presentWakeAlarm(reason: String, confidence: Double) {
        DispatchQueue.main.async {
            guard !self.isPresenting else { return }
            self.isPresenting = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.startSound()
            self.showAlarmWindow(reason: reason, confidence: confidence)
        }
    }

    func dismissWakeAlarm() {
        DispatchQueue.main.async {
            self.audioPlayer?.stop()
            self.audioPlayer = nil
            self.alarmWindow?.isHidden = true
            self.alarmWindow = nil
            self.isPresenting = false
            WatchConnectivityReceiver.shared.endWatchSession()
        }
    }

    private func startSound() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            let url = Bundle.main.url(forResource: "alarm_chime", withExtension: "caf")
                ?? Bundle.main.url(forResource: "grand_project-zen-wind-411951", withExtension: "mp3")
            guard let url else {
                AudioServicesPlaySystemSound(1005)
                return
            }

            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 1.0
            player.prepareToPlay()
            player.play()
            audioPlayer = player
        } catch {
            AudioServicesPlaySystemSound(1005)
        }
    }

    private func showAlarmWindow(reason: String, confidence: Double) {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            return
        }

        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        window.rootViewController = WakeAlarmViewController(reason: reason, confidence: confidence)
        window.makeKeyAndVisible()
        alarmWindow = window
    }
}

private final class WakeAlarmViewController: UIViewController {
    private let reason: String
    private let confidence: Double

    init(reason: String, confidence: Double) {
        self.reason = reason
        self.confidence = confidence
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = WakeWellTheme.background

        let titleLabel = UILabel()
        titleLabel.text = "SetSail"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = WakeWellTheme.labelPrimary
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Good morning. Your smart alarm found a good wake moment."
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        subtitleLabel.textColor = WakeWellTheme.labelSecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center

        let detailLabel = UILabel()
        detailLabel.text = "Reason: \(reason)\nConfidence: \(Int((confidence * 100).rounded()))%"
        detailLabel.font = .systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = WakeWellTheme.labelSecondary
        detailLabel.numberOfLines = 0
        detailLabel.textAlignment = .center

        let dismissButton = UIButton(type: .system)
        WakeWellTheme.stylePrimaryButton(dismissButton, cornerRadius: 18)
        dismissButton.setTitle("Stop Alarm", for: .normal)
        dismissButton.addTarget(self, action: #selector(stopAlarm), for: .touchUpInside)

        let ritualButton = UIButton(type: .system)
        WakeWellTheme.styleSecondaryButton(ritualButton)
        ritualButton.setTitle("Start Rise Ritual on Watch", for: .normal)
        ritualButton.addTarget(self, action: #selector(startRitual), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, detailLabel, dismissButton, ritualButton])
        stack.axis = .vertical
        stack.spacing = 18
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dismissButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    @objc private func stopAlarm() {
        AlarmPresentationManager.shared.dismissWakeAlarm()
    }

    @objc private func startRitual() {
        WatchConnectivityReceiver.shared.startRiseRitualOnWatch()
        AlarmPresentationManager.shared.dismissWakeAlarm()
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
                self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if granted {
                        self.registerNotificationCategory()
                    }

                    completion?(granted)
                }
            case .denied:
                completion?(false)
            @unknown default:
                completion?(false)
            }
        }
    }

    func scheduleSmartAlarmWindow(baseTime: Date) {
        requestAuthorizationIfNeeded { [weak self] granted in
            guard let self, granted else {
                return
            }

            let normalizedBaseTime = self.normalizedBaseTime(from: baseTime)
            let fireDates = [normalizedBaseTime].filter { $0 > Date().addingTimeInterval(1) }

            guard !fireDates.isEmpty else {
                return
            }

            self.registerNotificationCategory()

            for (index, fireDate) in fireDates.enumerated() {
                let identifier = "\(self.scheduledPrefix).\(Int(normalizedBaseTime.timeIntervalSince1970)).\(index)"
                let content = self.makeAlarmContent(
                    title: "Rise & Shine",
                    subtitle: "Your alarm",
                    body: "SetSail is ready to wake you.",
                    fireDate: fireDate,
                    isImmediate: false
                )

                let components = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second],
                    from: fireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                self.notificationCenter.add(request) { _ in }
            }
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

                completion?()
            }
        }
    }

    func triggerImmediateAlarm() {
        cancelAllScheduledAlarms { [weak self] in
            guard let self else { return }

            self.requestAuthorizationIfNeeded { granted in
                guard granted else {
                    return
                }

                let fireDate = Date().addingTimeInterval(1)
                let identifier = "\(self.immediatePrefix).\(UUID().uuidString)"
                let content = self.makeAlarmContent(
                    title: "Wake Now",
                    subtitle: "Smart wake trigger",
                    body: "SetSail detected the right wake moment.",
                    fireDate: fireDate,
                    isImmediate: true
                )

                let components = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second],
                    from: fireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                self.notificationCenter.add(request) { _ in }
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

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case "STOP_ALARM", UNNotificationDismissActionIdentifier:
            AlarmPresentationManager.shared.dismissWakeAlarm()
        case "START_RITUAL":
            WatchConnectivityReceiver.shared.startRiseRitualOnWatch()
            AlarmPresentationManager.shared.dismissWakeAlarm()
        default:
            break
        }

        completionHandler()
    }
}
