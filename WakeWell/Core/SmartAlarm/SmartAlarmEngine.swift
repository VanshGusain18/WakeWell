import Foundation

final class SmartAlarmEngine {
    
    static let shared = SmartAlarmEngine()
    
    private var hasTriggered = false
    
    // MARK: - Public
    
    func reset() {
        hasTriggered = false
        print("🔄 Engine reset")
    }
    
    func evaluateWakeOpportunity() -> Bool {
        
        // ✅ 1. REQUIRE ALARM
        guard let wakeTime = AlarmManager.shared.getWakeTime() else {
            print("⛔ No alarm set")
            return false
        }
        
        let now = Date()
        let windowStart = wakeTime.addingTimeInterval(-30 * 60)
        
        // ✅ 2. WAKE WINDOW CHECK
        if now < windowStart || now > wakeTime {
            print("⏳ Outside wake window")
            return false
        }
        
        // ✅ 3. FETCH DATA
        let vitals = DatabaseManager.shared.fetchRecentVitals(limit: 20)
        let windowSize = min(5, vitals.count)
        
        // 🔒 HARD SAFETY: prevent noisy triggers
        guard windowSize >= 3 else {
            print("⚠️ Not enough vitals")
            return false
        }
        
        let recent = vitals
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(windowSize)
        
        // ✅ 4. AVERAGES
        let avgHR = recent.map { $0.heartRate }.reduce(0, +) / Double(recent.count)
        let avgHRV = recent.map { $0.hrv }.reduce(0, +) / Double(recent.count)
        let avgMotion = recent.map { $0.motion }.reduce(0, +) / Double(recent.count)
        
        let hrScore = normalize(avgHR, minValue: 50, maxValue: 100)
        let hrvScore = normalize(avgHRV, minValue: 20, maxValue: 80)
        let motionScore = avgMotion
        
        let wakeScore =
        0.4 * hrScore +
        0.3 * (1 - hrvScore) +
        0.3 * motionScore
        
        print("🔥 Base Score:", wakeScore)
        
        // ✅ 5. LIGHT INTELLIGENCE (TREND)
        let trendBoost = detectHRTrend(recent)
        let finalScore = wakeScore + trendBoost
        
        print("📈 Final Score:", finalScore)
        
        // ✅ 6. TRIGGER ONCE ONLY
        let isMotionHigh = avgMotion > 0.4
        let isHRRising = detectHRTrend(recent) > 0
        
        if finalScore > 0.48 && (isMotionHigh || isHRRising) && !hasTriggered {
            hasTriggered = true
            triggerAlarm()
            return true
        }
        
        return false
    }
    
    // MARK: - Private
    
    private func triggerAlarm() {
        print("⏰ WAKE UP TRIGGERED")
    }
    
    private func normalize(_ value: Double, minValue: Double, maxValue: Double) -> Double {
        let normalized = (value - minValue) / (maxValue - minValue)
        return Swift.max(0, Swift.min(1, normalized))
    }
    
    // 🔥 Simple rising HR detection
    private func detectHRTrend(_ data: ArraySlice<WatchVitalsModel>) -> Double {
        
        let values = data.map { $0.heartRate }
        guard values.count >= 3 else { return 0 }
        
        let isRising = values.last! > values.first!
        return isRising ? 0.05 : 0
    }
}
