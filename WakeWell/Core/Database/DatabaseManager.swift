import Foundation
import SQLite3

final class DatabaseManager {

    static let shared = DatabaseManager()

    private init() {}

    private var dbURL: URL {
        guard let url = Bundle.main.url(forResource: "wakewell_v2", withExtension: "sqlite3") else {
            fatalError("❌ Database file not found in bundle")
        }
        return url
    }

    func fetchLatestSession() -> SleepSessionModel? {

        var db: OpaquePointer?

        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("❌ Unable to open database")
            return nil
        }

        defer { sqlite3_close(db) }

        let query = """
        SELECT * FROM sleep_sessions
        ORDER BY bedtime_start DESC
        LIMIT 1;
        """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            print("❌ Failed to prepare query")
            return nil
        }

        defer { sqlite3_finalize(statement) }

        if sqlite3_step(statement) == SQLITE_ROW {

            let id = Int(sqlite3_column_int(statement, 0))

            let bedtimeString = String(cString: sqlite3_column_text(statement, 1))
            let wakeString = String(cString: sqlite3_column_text(statement, 2))

            let formatter = ISO8601DateFormatter()

            let bedtime = formatter.date(from: bedtimeString) ?? Date()
            let wake = formatter.date(from: wakeString) ?? Date()

            return SleepSessionModel(
                id: id,
                bedtimeStart: bedtime,
                wakeTime: wake,
                coreMinutes: Int(sqlite3_column_int(statement, 3)),
                deepMinutes: Int(sqlite3_column_int(statement, 4)),
                remMinutes: Int(sqlite3_column_int(statement, 5)),
                awakeMinutes: Int(sqlite3_column_int(statement, 6)),
                asleepMinutes: Int(sqlite3_column_int(statement, 7)),
                inBedMinutes: Int(sqlite3_column_int(statement, 8)),
                efficiency: sqlite3_column_double(statement, 9),
                awakeningCount: Int(sqlite3_column_int(statement, 10)),
                longestBlock: Int(sqlite3_column_int(statement, 11)),
                restlessnessScore: sqlite3_column_double(statement, 12),
                avgHR: Int(sqlite3_column_int(statement, 13)),
                hrv: sqlite3_column_double(statement, 14),
                respiratoryRate: sqlite3_column_double(statement, 15),
                wristTemp: sqlite3_column_double(statement, 16),
                oxygenSaturation: sqlite3_column_double(statement, 17),
                triggerReason: String(cString: sqlite3_column_text(statement, 18)),
                movementAtWake: sqlite3_column_double(statement, 19)
            )
        }

        return nil
    }
}
