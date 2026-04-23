import Foundation

final class AlarmManager {

    static let shared = AlarmManager()

    private init() {}

    private var currentAlarm: AlarmModel?

    private let alarmKey = "wakewell_alarm_time"
    
    // MARK: - Public API

    func setAlarm(_ alarm: AlarmModel) {
        self.currentAlarm = alarm

        if let time = alarm.time {
            UserDefaults.standard.set(time.timeIntervalSince1970, forKey: alarmKey)
        }

        print("⏰ Alarm set for:", alarm.time ?? Date())
    }

    func getAlarm() -> AlarmModel? {
        return currentAlarm
    }

    func getWakeTime() -> Date? {
        return currentAlarm?.time
    }

    // MARK: - Dev Helper

    func setTestAlarm() {
        let testTime = Date().addingTimeInterval(5 * 60)
        self.currentAlarm = AlarmModel(time: testTime)
        print("🧪 Test alarm set for:", testTime)
    }
    
    func loadSavedAlarm() {

        let timestamp = UserDefaults.standard.double(forKey: alarmKey)

        guard timestamp > 0 else { return }

        let date = Date(timeIntervalSince1970: timestamp)
        self.currentAlarm = AlarmModel(time: date)

        print("📦 Loaded saved alarm:", date)
    }
    
}
