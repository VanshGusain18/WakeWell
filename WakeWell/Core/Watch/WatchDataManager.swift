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

        print("Processing Vitals at:", data.timestamp)

        DatabaseManager.shared.insertWatchVitals(data)
    }

    func stop() {
        dataSource.stopStreaming()
    }
}
