import Combine
import Foundation

enum DataSourceState {
    case waitingForWatch
    case liveWatch
}

final class AppConnectionState: ObservableObject {
    static let shared = AppConnectionState()

    @Published var state: DataSourceState = .waitingForWatch
    @Published var lastPayloadTime: Date? = nil

    private init() {}

    func markWatchPayloadReceived() {
        if Thread.isMainThread {
            applyWatchPayloadReceived()
        } else {
            DispatchQueue.main.sync {
                applyWatchPayloadReceived()
            }
        }
    }

    private func applyWatchPayloadReceived() {
        lastPayloadTime = Date()
        if state != .liveWatch {
            print("🟢 Switching to LIVE WATCH mode")
            state = .liveWatch
        }
    }
}

final class LiveVitalsViewModel: ObservableObject {
    static let shared = LiveVitalsViewModel()

    @Published var heartRate: Double = 0
    @Published var motion: Double = 0
    @Published var hrv: Double = 0
    @Published var hrvStatus: String = "unavailable"
    @Published var alertStatus: String = "Monitoring"
    @Published var lastUpdated: Date?

    private init() {}

    func update(heartRate: Double, motion: Double, hrv: Double, hrvStatus: String = "HealthKit") {
        if Thread.isMainThread {
            applyUpdate(heartRate: heartRate, motion: motion, hrv: hrv, hrvStatus: hrvStatus)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.applyUpdate(heartRate: heartRate, motion: motion, hrv: hrv, hrvStatus: hrvStatus)
            }
        }
    }

    func updateAlertStatus(_ status: String) {
        DispatchQueue.main.async { [weak self] in
            self?.alertStatus = status
        }
    }

    private func applyUpdate(heartRate: Double, motion: Double, hrv: Double, hrvStatus: String) {
        self.heartRate = heartRate
        self.motion = motion
        self.hrv = hrv
        self.hrvStatus = hrvStatus
        self.lastUpdated = Date()
    }
}
