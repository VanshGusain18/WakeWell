import Foundation

final class WatchDataManager {

    static let shared = WatchDataManager()

    private let dataSource: WatchDataSource

    private(set) var latestData: WatchData?

    private init() {
        self.dataSource = MockWatchDataSource()
    }

    func syncData(completion: (() -> Void)? = nil) {

        print("Sync started...")

        dataSource.fetchLatestData { [weak self] data in

            guard let self = self else { return }

            self.latestData = data

            print("Data stored in manager: \(String(describing: data))")

            completion?()
        }
    }
}
