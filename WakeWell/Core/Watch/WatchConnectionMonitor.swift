import Foundation
import WatchConnectivity

enum WatchConnectionState {
    case connected
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

    func markPayloadReceived(at date: Date = Date()) {
        lastReceivedTimestamp = date
        isReachable = WCSession.default.isReachable
        transition(to: .connected)
    }

    func updateReachability(_ reachable: Bool) {
        isReachable = reachable
        transition(to: reachable ? .connected : .disconnected)
    }

    private func transition(to nextState: WatchConnectionState) {
        guard nextState != state else { return }
        state = nextState

        switch nextState {
        case .connected:
            print("WATCH CONNECTED")
        case .disconnected:
            print("WATCH DISCONNECTED - FREEZING ENGINE")
        case .unknown:
            break
        }
    }
}
