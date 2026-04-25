import Foundation

final class WatchDataManager {

    static let shared = WatchDataManager()

    var useSimulation = true {
        didSet {
            configureProvider()
        }
    }

    private var provider: VitalDataProvider = MockWatchProvider()

    private init() {
        configureProvider()
    }

    func setProvider(_ provider: VitalDataProvider) {
        stop()
        self.provider = provider
        configureProviderCallback()
    }

    func start(resetData: Bool = true) {
        stop()

        if resetData {
            DatabaseManager.shared.clearVitals()
            SmartAlarmEngine.shared.reset()
        }

        SmartAlarmEngine.shared.beginMonitoring()
        print("[STATE] Using provider:", useSimulation ? "MockWatchProvider" : "RealWatchProvider")
        provider.start()
    }

    func startDemo() {
        resetDemoEnvironment()

        let alarmTime = Date().addingTimeInterval(5 * 60)
        AlarmManager.shared.setAlarm(AlarmModel(time: alarmTime))
        NotificationCenter.default.post(name: .alarmTimeDidChange, object: nil)

        start(resetData: false)
    }

    func resetDemoEnvironment() {
        stop()
        NotificationManager.shared.cancelAllScheduledAlarms()
        DatabaseManager.shared.clearVitals()
        SmartAlarmEngine.shared.reset()
    }

    private func configureProvider() {
        provider = useSimulation ? MockWatchProvider() : RealWatchProvider()
        configureProviderCallback()
    }

    private func configureProviderCallback() {
        provider.onData = { [weak self] data in
            self?.handleIncomingData(data)
        }
    }

    private func handleIncomingData(_ data: VitalData) {
        SmartAlarmEngine.shared.recordCurrentInput(
            heartRate: data.heartRate,
            hrv: data.hrv,
            motion: data.motion,
            phase: data.phase
        )

        DatabaseManager.shared.insertWatchVitals(data.watchVitalsModel)

        let decision = SmartAlarmEngine.shared.evaluateWakeOpportunity()

        if decision.shouldTrigger {
            NotificationManager.shared.triggerImmediateAlarm()
            SleepSessionManager.shared.endSession(
                triggerTime: Date(),
                reason: decision.reason,
                confidence: decision.confidence
            )
            stop()
        }
    }

    func stop() {
        provider.stop()
    }
}
