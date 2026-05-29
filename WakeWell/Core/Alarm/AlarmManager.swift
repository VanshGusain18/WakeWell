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
    private weak var presentedController: AlarmRingViewController?
    private var isPresenting = false

    private init() {}

    func presentWakeAlarm(
        reason: String,
        confidence: Double,
        wakeDate: Date = Date(),
        source: AlarmWakeSource = .smartAlarm
    ) {
        DispatchQueue.main.async {
            if self.isPresenting {
                self.presentedController?.update(reason: reason, confidence: confidence, wakeDate: wakeDate, source: source)
                return
            }

            guard let presenter = UIApplication.shared.activeTopViewController else {
                AlarmDeepLinkCoordinator.shared.pendingWakeRequest = AlarmWakeRequest(
                    reason: reason,
                    confidence: confidence,
                    wakeDate: wakeDate,
                    source: source
                )
                return
            }

            self.isPresenting = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self.startSound()
            let controller = AlarmRingViewController(
                reason: reason,
                confidence: confidence,
                wakeDate: wakeDate,
                source: source
            )
            controller.modalPresentationStyle = .fullScreen
            self.presentedController = controller
            presenter.present(controller, animated: true)
        }
    }

    func dismissWakeAlarm(startRiseRitual: Bool = false, cancelPendingAlerts: Bool = true) {
        DispatchQueue.main.async {
            if cancelPendingAlerts {
                NotificationManager.shared.cancelAllScheduledAlarms()
            }
            self.audioPlayer?.stop()
            self.audioPlayer = nil
            self.presentedController?.dismiss(animated: true)
            self.presentedController = nil
            self.isPresenting = false
            WatchConnectivityReceiver.shared.endWatchSession()

            if startRiseRitual {
                AlarmDeepLinkCoordinator.shared.openRiseRitual()
            }
        }
    }

    func snoozeWakeAlarm() {
        NotificationManager.shared.snoozeAlarm()
        dismissWakeAlarm(startRiseRitual: false, cancelPendingAlerts: false)
    }

    private func startSound() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            let url = Bundle.main.url(forResource: "setsail_alarm", withExtension: "wav")
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
}

enum AlarmWakeSource: String {
    case scheduled
    case repeatAlert
    case snooze
    case smartAlarm
}

struct AlarmWakeRequest {
    let reason: String
    let confidence: Double
    let wakeDate: Date
    let source: AlarmWakeSource
}

final class AlarmDeepLinkCoordinator {
    static let shared = AlarmDeepLinkCoordinator()

    var pendingWakeRequest: AlarmWakeRequest?

    private init() {}

    func openAlarm(_ request: AlarmWakeRequest) {
        pendingWakeRequest = request
        NotificationCenter.default.post(name: .setSailOpenAlarmScreen, object: nil)
    }

    func openRiseRitual() {
        NotificationCenter.default.post(name: .setSailOpenRiseRitual, object: nil)
    }

    func processPendingAlarmIfNeeded() {
        guard let request = pendingWakeRequest else { return }
        pendingWakeRequest = nil
        AlarmPresentationManager.shared.presentWakeAlarm(
            reason: request.reason,
            confidence: request.confidence,
            wakeDate: request.wakeDate,
            source: request.source
        )
    }
}

extension Notification.Name {
    static let setSailOpenAlarmScreen = Notification.Name("setsail.openAlarmScreen")
    static let setSailOpenRiseRitual = Notification.Name("setsail.openRiseRitual")
}

private extension UIApplication {
    var activeTopViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostPresentedViewController
    }
}

private extension UIViewController {
    var topMostPresentedViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.topMostPresentedViewController
        }
        if let navigationController = self as? UINavigationController,
           let visible = navigationController.visibleViewController {
            return visible.topMostPresentedViewController
        }
        if let tabBarController = self as? UITabBarController,
           let selected = tabBarController.selectedViewController {
            return selected.topMostPresentedViewController
        }
        return self
    }
}

final class AlarmRingViewController: UIViewController {
    private var reason: String
    private var confidence: Double
    private var wakeDate: Date
    private var source: AlarmWakeSource

    private let gradientLayer = CAGradientLayer()
    private let timeLabel = UILabel()
    private let readinessLabel = UILabel()
    private let reasonLabel = UILabel()
    private let sourceLabel = UILabel()
    private let ringContainer = UIView()
    private let readinessRing = CAShapeLayer()
    private var timeTimer: Timer?

    init(reason: String, confidence: Double, wakeDate: Date, source: AlarmWakeSource) {
        self.reason = reason
        self.confidence = confidence
        self.wakeDate = wakeDate
        self.source = source
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        configureContent()
        updateLabels()
        startClock()
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        updateReadinessRingPath()
    }

    deinit {
        timeTimer?.invalidate()
    }

    func update(reason: String, confidence: Double, wakeDate: Date, source: AlarmWakeSource) {
        self.reason = reason
        self.confidence = confidence
        self.wakeDate = wakeDate
        self.source = source
        updateLabels()
        animateReadinessRing()
    }

    private func configureBackground() {
        view.backgroundColor = WakeWellTheme.background
        gradientLayer.colors = [
            UIColor(red: 0.12, green: 0.10, blue: 0.28, alpha: 1).cgColor,
            UIColor(red: 0.38, green: 0.24, blue: 0.58, alpha: 1).cgColor,
            UIColor(red: 0.98, green: 0.71, blue: 0.31, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.1, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.45, 1.0]
        animation.toValue = [0.0, 0.72, 1.0]
        animation.duration = 5.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "alarmGradientDrift")
    }

    private func configureContent() {
        let brandLabel = UILabel()
        brandLabel.text = "SetSail"
        brandLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        brandLabel.textColor = .white.withAlphaComponent(0.82)
        brandLabel.textAlignment = .center

        let greetingLabel = UILabel()
        greetingLabel.text = "Good Morning"
        greetingLabel.font = .systemFont(ofSize: 38, weight: .bold)
        greetingLabel.textColor = .white
        greetingLabel.textAlignment = .center

        timeLabel.font = .monospacedDigitSystemFont(ofSize: 64, weight: .semibold)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center

        readinessLabel.font = .systemFont(ofSize: 22, weight: .bold)
        readinessLabel.textColor = .white
        readinessLabel.textAlignment = .center

        reasonLabel.font = .systemFont(ofSize: 16, weight: .medium)
        reasonLabel.textColor = .white.withAlphaComponent(0.82)
        reasonLabel.numberOfLines = 0
        reasonLabel.textAlignment = .center

        sourceLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        sourceLabel.textColor = .white.withAlphaComponent(0.68)
        sourceLabel.textAlignment = .center

        ringContainer.translatesAutoresizingMaskIntoConstraints = false
        ringContainer.layer.addSublayer(readinessRing)

        let stopButton = UIButton(type: .system)
        stopButton.setTitle("Dismiss & Start Ritual", for: .normal)
        stopButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        stopButton.tintColor = WakeWellTheme.labelPrimary
        stopButton.backgroundColor = WakeWellTheme.accentGold
        stopButton.layer.cornerRadius = 18
        stopButton.addTarget(self, action: #selector(stopAlarm), for: .touchUpInside)

        let snoozeButton = UIButton(type: .system)
        snoozeButton.setTitle("Snooze 9 min", for: .normal)
        snoozeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        snoozeButton.tintColor = .white
        snoozeButton.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        snoozeButton.layer.cornerRadius = 18
        snoozeButton.layer.borderWidth = 1
        snoozeButton.layer.borderColor = UIColor.white.withAlphaComponent(0.24).cgColor
        snoozeButton.addTarget(self, action: #selector(snoozeAlarm), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [stopButton, snoozeButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let contentStack = UIStackView(arrangedSubviews: [
            brandLabel,
            greetingLabel,
            timeLabel,
            ringContainer,
            readinessLabel,
            reasonLabel,
            sourceLabel
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentStack)
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -32),

            ringContainer.heightAnchor.constraint(equalToConstant: 118),

            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            stopButton.heightAnchor.constraint(equalToConstant: 58),
            snoozeButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    private func updateLabels() {
        let percent = max(0, min(100, Int((confidence * 100).rounded())))
        readinessLabel.text = "\(percent)% wake readiness"
        reasonLabel.text = reason
        sourceLabel.text = "\(sourceDescription) • \(Self.wakeTimeFormatter.string(from: wakeDate))"
        timeLabel.text = Self.timeFormatter.string(from: Date())
    }

    private var sourceDescription: String {
        switch source {
        case .scheduled:
            return "Scheduled alarm"
        case .repeatAlert:
            return "Follow-up alert"
        case .snooze:
            return "Snoozed alarm"
        case .smartAlarm:
            return "Smart wake moment"
        }
    }

    private func startClock() {
        timeLabel.text = Self.timeFormatter.string(from: Date())
        timeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.timeLabel.text = Self.timeFormatter.string(from: Date())
        }
    }

    private func updateReadinessRingPath() {
        let bounds = ringContainer.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius: CGFloat = 48
        readinessRing.frame = bounds
        let track = CAShapeLayer()
        track.path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: .pi * 1.5,
            clockwise: true
        ).cgPath
        track.strokeColor = UIColor.white.withAlphaComponent(0.18).cgColor
        track.fillColor = UIColor.clear.cgColor
        track.lineWidth = 9

        readinessRing.sublayers?.forEach { $0.removeFromSuperlayer() }
        readinessRing.addSublayer(track)
        readinessRing.path = track.path
        readinessRing.strokeColor = WakeWellTheme.accentGold.cgColor
        readinessRing.fillColor = UIColor.clear.cgColor
        readinessRing.lineCap = .round
        readinessRing.lineWidth = 9
        readinessRing.strokeEnd = max(0.08, min(1, confidence))
    }

    private func animateReadinessRing() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = max(0.08, min(1, confidence))
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        readinessRing.add(animation, forKey: "readiness")
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter
    }()

    private static let wakeTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    @objc private func stopAlarm() {
        AlarmPresentationManager.shared.dismissWakeAlarm(startRiseRitual: true)
    }

    @objc private func snoozeAlarm() {
        AlarmPresentationManager.shared.snoozeWakeAlarm()
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
    private let repeatPrefix = "wakewell.smartAlarm.repeat"
    private let snoozePrefix = "wakewell.smartAlarm.snooze"
    private let notificationCategory = "WAKEWELL_ALARM"
    private let snoozeActionIdentifier = "SNOOZE_ALARM"
    private let openActionIdentifier = "OPEN_SETSAIL_ALARM"
    private let stopActionIdentifier = "STOP_ALARM"
    private let customSoundName = "setsail_alarm.wav"
    private let snoozeInterval: TimeInterval = 9 * 60
    private let repeatIntervals: [TimeInterval] = [2 * 60, 5 * 60, 10 * 60]

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
            let fireDates = self.alarmFireDates(for: normalizedBaseTime)

            guard !fireDates.isEmpty else {
                return
            }

            self.registerNotificationCategory()
            self.removePendingAlarmNotifications {
                for (index, fireDate) in fireDates.enumerated() {
                    let source: AlarmWakeSource = index == 0 ? .scheduled : .repeatAlert
                    let prefix = index == 0 ? self.scheduledPrefix : self.repeatPrefix
                    let identifier = "\(prefix).\(Int(normalizedBaseTime.timeIntervalSince1970)).\(index)"
                    let content = self.makeAlarmContent(
                        title: index == 0 ? "Rise & Shine" : "Still time to wake up",
                        subtitle: index == 0 ? "Your SetSail alarm" : "Alarm follow-up",
                        body: index == 0 ? "SetSail is ready to wake you." : "Open SetSail to stop or snooze your alarm.",
                        fireDate: fireDate,
                        source: source,
                        confidence: 0.86
                    )

                    self.addNotification(identifier: identifier, content: content, fireDate: fireDate)
                }
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
                    source: .smartAlarm,
                    confidence: SmartAlarmEngine.shared.currentWakeConfidence
                )

                self.addNotification(identifier: identifier, content: content, fireDate: fireDate)
            }
        }
    }

    func snoozeAlarm() {
        requestAuthorizationIfNeeded { [weak self] granted in
            guard let self, granted else { return }
            self.removePendingAlarmNotifications {
                let fireDate = Date().addingTimeInterval(self.snoozeInterval)
                let identifier = "\(self.snoozePrefix).\(Int(fireDate.timeIntervalSince1970))"
                let content = self.makeAlarmContent(
                    title: "Snoozed Alarm",
                    subtitle: "SetSail",
                    body: "Your snoozed alarm is ringing.",
                    fireDate: fireDate,
                    source: .snooze,
                    confidence: SmartAlarmEngine.shared.currentWakeConfidence
                )
                self.addNotification(identifier: identifier, content: content, fireDate: fireDate)
            }
        }
    }

    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let request = wakeRequest(from: response.notification.request.content)

        switch response.actionIdentifier {
        case stopActionIdentifier, UNNotificationDismissActionIdentifier:
            AlarmPresentationManager.shared.dismissWakeAlarm(startRiseRitual: false)
        case snoozeActionIdentifier:
            snoozeAlarm()
            AlarmPresentationManager.shared.dismissWakeAlarm(startRiseRitual: false)
        case openActionIdentifier, UNNotificationDefaultActionIdentifier:
            AlarmDeepLinkCoordinator.shared.openAlarm(request)
        default:
            AlarmDeepLinkCoordinator.shared.openAlarm(request)
        }
    }

    // MARK: - Private

    private func normalizedBaseTime(from baseTime: Date) -> Date {
        if baseTime > Date() {
            return baseTime
        }

        return Calendar.current.date(byAdding: .day, value: 1, to: baseTime) ?? baseTime
    }

    private func alarmFireDates(for baseTime: Date) -> [Date] {
        ([0] + repeatIntervals)
            .map { baseTime.addingTimeInterval($0) }
            .filter { $0 > Date().addingTimeInterval(1) }
    }

    private func addNotification(identifier: String, content: UNNotificationContent, fireDate: Date) {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request) { _ in }
    }

    private func makeAlarmContent(
        title: String,
        subtitle: String,
        body: String,
        fireDate: Date,
        source: AlarmWakeSource,
        confidence: Double
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = alarmSound()
        content.categoryIdentifier = notificationCategory
        content.threadIdentifier = notificationCategory
        content.targetContentIdentifier = notificationCategory

        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 1.0
        }

        content.userInfo = [
            "wakeTime": ISO8601DateFormatter().string(from: fireDate),
            "source": source.rawValue,
            "confidence": confidence,
            "reason": body
        ]

        return content
    }

    private func alarmSound() -> UNNotificationSound {
        if Bundle.main.url(forResource: "setsail_alarm", withExtension: "wav") != nil {
            return UNNotificationSound(named: UNNotificationSoundName(customSoundName))
        }

        return .default
    }

    private func registerNotificationCategory() {
        let stopAction = UNNotificationAction(
            identifier: stopActionIdentifier,
            title: "Stop",
            options: [.destructive]
        )

        let snoozeAction = UNNotificationAction(
            identifier: snoozeActionIdentifier,
            title: "Snooze",
            options: []
        )

        let openAction = UNNotificationAction(
            identifier: openActionIdentifier,
            title: "Open SetSail",
            options: [.foreground]
        )

        let category = UNNotificationCategory(
            identifier: notificationCategory,
            actions: [snoozeAction, openAction, stopAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "Alarm",
            options: [.customDismissAction]
        )

        notificationCenter.setNotificationCategories([category])
    }

    private func isWakeWellAlarmIdentifier(_ identifier: String) -> Bool {
        identifier.hasPrefix(scheduledPrefix)
            || identifier.hasPrefix(immediatePrefix)
            || identifier.hasPrefix(repeatPrefix)
            || identifier.hasPrefix(snoozePrefix)
    }

    private func removePendingAlarmNotifications(completion: @escaping () -> Void) {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            guard let self else {
                completion()
                return
            }

            let ids = requests
                .map(\.identifier)
                .filter { self.isWakeWellAlarmIdentifier($0) }
            if !ids.isEmpty {
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
            }
            completion()
        }
    }

    private func wakeRequest(from content: UNNotificationContent) -> AlarmWakeRequest {
        let userInfo = content.userInfo
        let wakeDate = (userInfo["wakeTime"] as? String)
            .flatMap { ISO8601DateFormatter().date(from: $0) } ?? Date()
        let confidence = userInfo["confidence"] as? Double ?? 0.86
        let source = (userInfo["source"] as? String)
            .flatMap(AlarmWakeSource.init(rawValue:)) ?? .scheduled
        let reason = userInfo["reason"] as? String ?? content.body

        return AlarmWakeRequest(
            reason: reason,
            confidence: confidence,
            wakeDate: wakeDate,
            source: source
        )
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let request = wakeRequest(from: notification.request.content)
        AlarmPresentationManager.shared.presentWakeAlarm(
            reason: request.reason,
            confidence: request.confidence,
            wakeDate: request.wakeDate,
            source: request.source
        )
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleNotificationResponse(response)
        completionHandler()
    }
}
