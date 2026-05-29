import Foundation

// NOTE: Renamed from AlarmViewModel → HomeAlarmViewModel to avoid collision
// with features/Alarm/ViewModel/AlarmViewModel (the alarm scheduling ViewModel).
struct HomeAlarmViewModel {

    let title: String
    let timeText: String
    let subtitleText: String
    let wakeWindowText: String
    let hasAlarm: Bool

    init(model: AlarmModel) {

        if let time = model.time {
            hasAlarm = true
            title = "Next wake session"
            timeText = Self.format(time: time)
            let windowStart = AlarmManager.shared.alarmWindowStart(for: time)
            wakeWindowText = "\(Self.format(time: windowStart)) - \(Self.format(time: time))"
            subtitleText = "Smart wake window enabled"
        } else {
            hasAlarm = false
            title = "No alarm configured"
            timeText = "Tap to set your alarm"
            wakeWindowText = "Smart wake begins after setup"
            subtitleText = "Choose a wake time when you are ready."
        }
    }

    private static func format(time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}
