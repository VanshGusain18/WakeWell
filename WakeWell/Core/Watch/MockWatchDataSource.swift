import Foundation

final class MockWatchDataSource: WatchDataSource {

    func fetchLatestData(completion: @escaping (WatchData?) -> Void) {

        print("Fetching data from MOCK watch...")

        let data = WatchData(
            sleepScore: Int.random(in: 60...95),
            duration: Int.random(in: 10...20),
            efficiency: Int.random(in: 8...15),
            architecture: Int.random(in: 15...25),
            continuity: Int.random(in: 10...15),
            calmness: Int.random(in: 8...15),
            consistency: Int.random(in: 5...10),
            timestamp: Date()
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Mock data generated: \(data)")
            completion(data)
        }
    }
}
