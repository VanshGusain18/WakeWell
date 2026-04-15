import Foundation

protocol WatchDataSource {
    func startStreaming(completion: @escaping (WatchVitalsModel) -> Void)
    func stopStreaming()
}
