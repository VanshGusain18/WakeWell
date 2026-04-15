import Foundation

final class MockWatchDataSource: WatchDataSource {

    private var timer: Timer?

    func startStreaming(completion: @escaping (WatchVitalsModel) -> Void) {

        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in

            let data = WatchVitalsModel(
                timestamp: Date(),
                heartRate: Double.random(in: 50...90),
                hrv: Double.random(in: 20...80),
                motion: Double.random(in: 0...1),
                respiratoryRate: Double.random(in: 12...20),
                wristTemp: Double.random(in: 36.0...37.5),
                oxygenSaturation: Double.random(in: 95...100)
            )

//            print("Mock Vitals:", data)

            completion(data)
        }
    }

    func stopStreaming() {
        timer?.invalidate()
        timer = nil
    }
}
