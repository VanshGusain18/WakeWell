import Foundation

enum StatsSampleData {
    enum Mode {
        case automatic
        case sampleOnly
        case liveOnly
    }

    /// Flip this in code when you want the stats screen to use the bundled fixture.
    /// - `.automatic`: live data when available, sample data only as a debug fallback
    /// - `.sampleOnly`: always use the bundled sample data in debug builds
    /// - `.liveOnly`: never use sample data
    static var mode: Mode = .sampleOnly

    static func records(for range: StatsTimeRange) -> [NightRecord] {
        switch mode {
        case .liveOnly:
            return []
        case .sampleOnly:
            return sampleRecords(for: range)
        case .automatic:
#if DEBUG
            return sampleRecords(for: range)
#else
            return []
#endif
        }
    }

    private static func sampleRecords(for range: StatsTimeRange) -> [NightRecord] {
#if DEBUG
        let sampleRecords = loadAllRecords()
        guard !sampleRecords.isEmpty else { return [] }
        return sampleRecords.filter { range.dateInterval.contains($0.date) }
            .sorted { $0.date < $1.date }
#else
        return []
#endif
    }

#if DEBUG
    private static func loadAllRecords() -> [NightRecord] {
        guard let url = Bundle.main.url(forResource: "StatsSampleData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let payloads = try? JSONDecoder().decode([StatsSampleNightRecordPayload].self, from: data) else {
            return []
        }

        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: Date())

        return payloads.compactMap { payload in
            guard let date = calendar.date(byAdding: .day,
                                           value: payload.offsetDays,
                                           to: baseDate) else {
                return nil
            }

            return NightRecord(
                date: date,
                hoursSlept: payload.hoursSlept,
                timeInBed: payload.timeInBed,
                deepHours: payload.deepHours,
                remHours: payload.remHours,
                lightHours: payload.lightHours,
                awakenings: payload.awakenings,
                totalAwakeMin: payload.totalAwakeMin,
                restingHR: payload.restingHR,
                hrv: payload.hrv,
                movementIndex: payload.movementIndex,
                bedtime: payload.bedtime,
                wakeTime: payload.wakeTime
            )
        }
    }

    private struct StatsSampleNightRecordPayload: Decodable {
        let offsetDays: Int
        let hoursSlept: Double
        let timeInBed: Double
        let deepHours: Double
        let remHours: Double
        let lightHours: Double
        let awakenings: Int
        let totalAwakeMin: Double
        let restingHR: Double
        let hrv: Double
        let movementIndex: Double
        let bedtime: Double
        let wakeTime: Double
    }
#endif
}
