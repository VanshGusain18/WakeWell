import Foundation

final class AlarmManager {

    static let shared = AlarmManager()

    private init() {}

    private var currentAlarm: AlarmModel?

    // MARK: - Public API

    func setAlarm(_ alarm: AlarmModel) {
        self.currentAlarm = alarm
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
}
