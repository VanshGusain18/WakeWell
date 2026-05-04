import Foundation

final class UnifiedVitalsAggregator {
    static let shared = UnifiedVitalsAggregator()

    var onVitalsReady: ((WatchVitals) -> Void)?

    private let aggregationWindow: TimeInterval = 10
    private let sendInterval: TimeInterval = 5
    private var heartRateSamples: [(timestamp: Date, value: Double)] = []
    private var motionSamples: [(timestamp: Date, value: Double)] = []
    private var lastHRVValue: Double?
    private var lastHRVTimestamp: Date?
    private var lastRespiratoryRateValue: Double?
    private var lastRespiratoryRateTimestamp: Date?
    private var hrvUnavailableReason = "system_delay"
    private var lastEmitTime: Date?
    private var emitTimer: Timer?

    private init() {}

    var latestHeartRate: Double {
        heartRateSamples.last?.value ?? 0
    }

    var averageMotion: Double {
        average(motionSamples)
    }

    var latestHRV: Double? {
        lastHRVValue
    }

    var latestHRVUpdatedAt: Date? {
        lastHRVTimestamp
    }

    func start() {
        stop()
        emitTimer = Timer.scheduledTimer(withTimeInterval: sendInterval, repeats: true) { [weak self] _ in
            self?.emitIfReady()
        }
    }

    func stop() {
        emitTimer?.invalidate()
        emitTimer = nil
        heartRateSamples.removeAll()
        motionSamples.removeAll()
        lastHRVValue = nil
        lastHRVTimestamp = nil
        lastRespiratoryRateValue = nil
        lastRespiratoryRateTimestamp = nil
        hrvUnavailableReason = "system_delay"
        lastEmitTime = nil
    }

    func addHeartRate(_ heartRate: Double) {
        append(value: heartRate, to: &heartRateSamples)
    }

    func addMotion(_ motion: Double) {
        append(value: motion, to: &motionSamples)
    }

    func updateHRV(_ hrv: Double, timestamp: Date) {
        lastHRVValue = hrv
        lastHRVTimestamp = timestamp
        hrvUnavailableReason = ""
    }

    func updateRespiratoryRate(_ respiratoryRate: Double, timestamp: Date) {
        lastRespiratoryRateValue = respiratoryRate
        lastRespiratoryRateTimestamp = timestamp
    }

    func markHRVUnavailable(reason: String) {
        lastHRVValue = nil
        hrvUnavailableReason = reason
    }

    private func emitIfReady() {
        let now = Date()
        if let lastEmitTime,
           now.timeIntervalSince(lastEmitTime) < sendInterval {
            return
        }

        guard !heartRateSamples.isEmpty else {
            print("Waiting for real HealthKit heart rate before sending vitals")
            return
        }

        let vitals = WatchVitals(
            heartRate: average(heartRateSamples),
            hrv: lastHRVValue,
            motion: average(motionSamples),
            respiratoryRate: lastRespiratoryRateValue,
            timestamp: now,
            hrvUnavailableReason: lastHRVValue == nil ? hrvUnavailableReason : nil
        )

        lastEmitTime = now
        print("SENDING AGGREGATED VITALS", vitals.payload)
        onVitalsReady?(vitals)
    }

    private func append(value: Double, to samples: inout [(timestamp: Date, value: Double)]) {
        let now = Date()
        samples.append((timestamp: now, value: value))
        samples.removeAll { now.timeIntervalSince($0.timestamp) > aggregationWindow }
    }

    private func average(_ samples: [(timestamp: Date, value: Double)]) -> Double {
        guard !samples.isEmpty else { return 0 }
        let total = samples.reduce(0) { $0 + $1.value }
        return total / Double(samples.count)
    }
}
