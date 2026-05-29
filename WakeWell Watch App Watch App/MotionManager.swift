import CoreMotion
import Foundation

final class MotionManager {
    static let shared = MotionManager()

    private let manager = CMMotionManager()
    private let rollingWindow: TimeInterval = 10
    private var samples: [(timestamp: Date, value: Double)] = []

    private init() {}

    func start(onUpdate: @escaping (Double) -> Void) {
        guard manager.isDeviceMotionAvailable else {
            return
        }

        manager.deviceMotionUpdateInterval = 1.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            if error != nil {
                return
            }

            guard let self, let data else { return }

            let accel = data.userAcceleration
            let magnitude = sqrt(
                accel.x * accel.x +
                accel.y * accel.y +
                accel.z * accel.z
            )
            let normalized = min(max(magnitude / 1.5, 0), 1)
            let average = self.appendAndAverage(normalized)

            onUpdate(average)
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        samples.removeAll()
    }

    private func appendAndAverage(_ value: Double) -> Double {
        let now = Date()
        samples.append((timestamp: now, value: value))
        samples.removeAll { now.timeIntervalSince($0.timestamp) > rollingWindow }

        guard !samples.isEmpty else { return value }

        let total = samples.reduce(0) { $0 + $1.value }
        return total / Double(samples.count)
    }
}
