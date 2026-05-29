import Foundation
import WatchConnectivity

enum WatchConnectionState {
    case connected
    case waiting
    case disconnected
    case unknown
}

final class WatchConnectionMonitor {
    static let shared = WatchConnectionMonitor()

    private let staleInterval: TimeInterval = 20
    private(set) var state: WatchConnectionState = .unknown
    private(set) var lastReceivedTimestamp: Date?
    private(set) var isReachable = false

    private init() {}

    var isStaleData: Bool {
        guard let lastReceivedTimestamp else { return true }
        return Date().timeIntervalSince(lastReceivedTimestamp) > staleInterval
    }

    var canEvaluateWakeDecision: Bool {
        state == .connected && !isStaleData
    }

    var displayStatus: String {
        guard WCSession.isSupported() else { return "Watch Connectivity Unavailable" }

        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else { return "Install SetSail on Apple Watch" }
        #endif

        if state == .connected && !isStaleData {
            return "Receiving Data"
        }

        if state == .disconnected {
            return "Disconnected"
        }

        return isReachable ? "Waiting for Live Data" : "Connecting to Apple Watch"
    }

    func markPayloadReceived(at date: Date = Date()) {
        performOnMain {
            self.lastReceivedTimestamp = date
            self.isReachable = WCSession.default.isReachable
            self.transition(to: .connected)
        }
    }

    func updateReachability(_ reachable: Bool) {
        performOnMain {
            self.isReachable = reachable
            self.transition(to: self.isStaleData ? .waiting : .connected)
        }
    }

    func markDeliveryQueued() {
        performOnMain {
            self.transition(to: self.isStaleData ? .waiting : .connected)
        }
    }

    func markUnavailable() {
        performOnMain {
            self.transition(to: .disconnected)
        }
    }

    private func performOnMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }

    private func transition(to nextState: WatchConnectionState) {
        guard nextState != state else { return }
        state = nextState
        NotificationCenter.default.post(name: .watchConnectionDidChange, object: nil)

    }
}

extension Notification.Name {
    static let watchConnectionDidChange = Notification.Name("wakewell.watchConnectionDidChange")
}
