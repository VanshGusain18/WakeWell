import Foundation

final class WatchDataManager {

    static let shared = WatchDataManager()

    private init() {}

    func process(vitalData: VitalData) {
        if Thread.isMainThread {
            handleIncomingData(vitalData)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.handleIncomingData(vitalData)
            }
        }
    }

    func start(resetData: Bool = true) {
        if resetData {
            DatabaseManager.shared.clearVitals()
            SmartAlarmEngine.shared.reset()
        }

        print("Using provider: LiveWatchPayloadStream")
        SmartAlarmEngine.shared.beginMonitoring()
    }

    func startDebugSession() {
        resetMonitoringState()
        start(resetData: false)
    }

    func resetDebugEnvironment() {
        resetMonitoringState()
    }

    func stop() {}

    private func resetMonitoringState() {
        NotificationManager.shared.cancelAllScheduledAlarms()
        DatabaseManager.shared.clearVitals()
        SmartAlarmEngine.shared.reset()
    }

    private func handleIncomingData(_ data: VitalData) {
        LiveVitalsViewModel.shared.update(
            heartRate: data.heartRate,
            motion: data.motion,
            hrv: data.hrv ?? 0,
            respiratoryRate: data.respiratoryRate,
            hrvStatus: data.hrv == nil ? "unavailable" : "HealthKit"
        )

        SmartAlarmEngine.shared.recordCurrentInput(
            heartRate: data.heartRate,
            hrv: data.hrv,
            motion: data.motion,
            phase: data.phase
        )

        DatabaseManager.shared.insertWatchVitals(data.watchVitalsModel)

        let decision = SmartAlarmEngine.shared.evaluateWakeOpportunity()

        if decision.shouldTrigger {
            LiveVitalsViewModel.shared.updateAlertStatus("Alert triggered")
            NotificationManager.shared.triggerImmediateAlarm()
            SleepSessionManager.shared.endSession(
                triggerTime: Date(),
                reason: decision.reason,
                confidence: decision.confidence
            )
            stop()
        } else {
            LiveVitalsViewModel.shared.updateAlertStatus(decision.reason)
        }
    }
}
