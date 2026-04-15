import Foundation

final class WatchDataManager {

    static let shared = WatchDataManager()

    private let dataSource: WatchDataSource = MockWatchDataSource()

    private init() {}

    func start() {
        dataSource.startStreaming { data in
            self.handleIncomingData(data)
        }
    }

    private func handleIncomingData(_ data: WatchVitalsModel) {

        DatabaseManager.shared.insertWatchVitals(data)

        let shouldWake = SmartAlarmEngine.shared.evaluateWakeOpportunity()

        if shouldWake {
            print("🔥 TRIGGER ALARM NOW")
        } else {
            print("😴 WAIT")
        }
    }

    func stop() {
        dataSource.stopStreaming()
    }
}
