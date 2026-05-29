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
            state = .liveWatch
        }
    }
}

final class LiveVitalsViewModel: ObservableObject {
    static let shared = LiveVitalsViewModel()

    @Published var heartRate: Double = 0
    @Published var motion: Double = 0
    @Published var hrv: Double = 0
    @Published var respiratoryRate: Double?
    @Published var hrvStatus: String = "unavailable"
    @Published var alertStatus: String = "Monitoring"
    @Published var lastUpdated: Date?

    private init() {}

    func update(heartRate: Double, motion: Double, hrv: Double, respiratoryRate: Double?, hrvStatus: String = "HealthKit") {
        if Thread.isMainThread {
            applyUpdate(heartRate: heartRate, motion: motion, hrv: hrv, respiratoryRate: respiratoryRate, hrvStatus: hrvStatus)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.applyUpdate(heartRate: heartRate, motion: motion, hrv: hrv, respiratoryRate: respiratoryRate, hrvStatus: hrvStatus)
            }
        }
    }

    func updateAlertStatus(_ status: String) {
        DispatchQueue.main.async { [weak self] in
            self?.alertStatus = status
        }
    }

    private func applyUpdate(heartRate: Double, motion: Double, hrv: Double, respiratoryRate: Double?, hrvStatus: String) {
        self.heartRate = heartRate
        self.motion = motion
        self.hrv = hrv
        self.respiratoryRate = respiratoryRate
        self.hrvStatus = hrvStatus
        self.lastUpdated = Date()
        NotificationCenter.default.post(name: .liveVitalsDidChange, object: nil)
    }
}

extension Notification.Name {
    static let liveVitalsDidChange = Notification.Name("wakewell.liveVitalsDidChange")
}
