import Foundation
import WatchConnectivity
import Combine

final class WatchConnectivityManager: NSObject, ObservableObject {

    static let shared = WatchConnectivityManager()

    @Published var lastHeartRate: Double = 0
    @Published var statusText = "Preparing stream..."

    private let session = WCSession.default
    private var timer: Timer?
    private var motionValue: Double = 0.15

    private override init() {
        super.init()
        activateSession()
        startStreaming()
    }

    private func activateSession() {
        guard WCSession.isSupported() else {
            statusText = "WCSession not supported"
            return
        }

        session.delegate = self
        session.activate()
        statusText = "Activating connection..."
    }

    func startStreaming() {
        stopStreaming()

        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.sendMockVitals()
        }
    }

    private func stopStreaming() {
        timer?.invalidate()
        timer = nil
    }

    private func sendMockVitals() {
        let heartRate = Double.random(in: 55...75)
        let hrv = Double.random(in: 50...80)
        motionValue = min(motionValue + 0.04, 0.95)

        let payload: [String: Any] = [
            "heartRate": heartRate,
            "motion": motionValue,
            "hrv": hrv,
            "timestamp": Date().timeIntervalSince1970
        ]

        lastHeartRate = heartRate

        guard session.isReachable else {
            statusText = "Waiting for iPhone..."
            return
        }

        session.sendMessage(payload, replyHandler: nil) { [weak self] error in
            DispatchQueue.main.async {
                self?.statusText = "Send failed: \(error.localizedDescription)"
            }
        }

        statusText = "Streaming to iPhone..."
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error {
                self.statusText = "Activation error: \(error.localizedDescription)"
            } else {
                self.statusText = "Streaming to iPhone..."
            }
        }
    }
}
