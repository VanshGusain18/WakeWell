import Foundation

protocol WatchDataSource {
    func fetchLatestData(completion: @escaping (WatchData?) -> Void)
}
