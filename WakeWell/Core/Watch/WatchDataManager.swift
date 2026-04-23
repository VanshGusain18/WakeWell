import Foundation

final class WatchDataManager {

    static let shared = WatchDataManager()

    private let dataSource: WatchDataSource = MockWatchDataSource()

    private init() {}

    func start() {

        // 🔥 CLEAN SESSION START
        DatabaseManager.shared.clearVitals()
        SmartAlarmEngine.shared.reset()

        dataSource.startStreaming { data in
            self.handleIncomingData(data)
        }
    }

    private func handleIncomingData(_ data: WatchVitalsModel) {

        DatabaseManager.shared.insertWatchVitals(data)

        let shouldWake = SmartAlarmEngine.shared.evaluateWakeOpportunity()

        if shouldWake {
            print("🔥 TRIGGER ALARM NOW")
            stop()
        } else {
            print("😴 WAIT")
        }
    }

    func stop() {
        dataSource.stopStreaming()
    }
}
