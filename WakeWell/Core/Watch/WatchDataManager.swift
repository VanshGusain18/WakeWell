import Foundation

final class WatchDataManager {

    static let shared = WatchDataManager()

    private let dataSource: WatchDataSource = MockWatchDataSource()

    private init() {}

    func start() {
        DatabaseManager.shared.clearVitals()
        SmartAlarmEngine.shared.reset()

        dataSource.startStreaming { data in
            self.handleIncomingData(data)
        }
    }

    private func handleIncomingData(_ data: WatchVitalsModel) {
        DatabaseManager.shared.insertWatchVitals(data)

        let decision = SmartAlarmEngine.shared.evaluateWakeOpportunity()

        if decision.shouldTrigger {
            print("[SmartAlarm] delivery requested")
            print("[SmartAlarm] confidence:", String(format: "%.3f", decision.confidence))
            print("[SmartAlarm] reason:", decision.reason)

            NotificationManager.shared.triggerImmediateAlarm()
            SleepSessionManager.shared.endSession(
                triggerTime: Date(),
                reason: decision.reason,
                confidence: decision.confidence
            )
            stop()
        } else {
            print("[SmartAlarm] waiting")
            print("[SmartAlarm] confidence:", String(format: "%.3f", decision.confidence))
            print("[SmartAlarm] reason:", decision.reason)
        }
    }

    func stop() {
        dataSource.stopStreaming()
    }
}
