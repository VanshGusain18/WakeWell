import Foundation
import SQLite3

final class DatabaseManager {

    static let shared = DatabaseManager()

    private init() {}

    private var dbURL: URL {

        let fileManager = FileManager.default

        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        let dbURL = documentsURL.appendingPathComponent("wakewell_v2.sqlite3")

        if !fileManager.fileExists(atPath: dbURL.path) {

            if let bundleURL = Bundle.main.url(forResource: "wakewell_v2", withExtension: "sqlite3") {
                try? fileManager.copyItem(at: bundleURL, to: dbURL)
                print("Database copied to Documents")
            } else {
                print("No preloaded DB found, creating new one")
            }
        }

//        print("DB PATH:", dbURL.path)
        
        return dbURL
    }

    func fetchLatestSession() -> SleepSessionModel? {

        var db: OpaquePointer?

        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Unable to open database")
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
            print("Failed to prepare query")
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

    func insertWatchVitals(_ data: WatchVitalsModel) {

        var db: OpaquePointer?

        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Unable to open database")
            return
        }

        defer { sqlite3_close(db) }

        let query = """
        INSERT INTO watch_vitals
        (timestamp, heart_rate, hrv, motion, respiratory_rate, wrist_temp, oxygen)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            print("Failed to prepare insert")
            return
        }

        defer { sqlite3_finalize(statement) }

        let formatter = ISO8601DateFormatter()

        sqlite3_bind_text(statement, 1, formatter.string(from: data.timestamp), -1, nil)
        sqlite3_bind_double(statement, 2, data.heartRate)
        sqlite3_bind_double(statement, 3, data.hrv)
        sqlite3_bind_double(statement, 4, data.motion)
        sqlite3_bind_double(statement, 5, data.respiratoryRate)
        sqlite3_bind_double(statement, 6, data.wristTemp ?? 0)
        sqlite3_bind_double(statement, 7, data.oxygenSaturation ?? 0)

        if sqlite3_step(statement) == SQLITE_DONE {
            print("Vitals inserted into DB")
        } else {
            print("Insert failed")
        }
    }
    
    func fetchRecentVitals(limit: Int = 20) -> [WatchVitalsModel] {

        var db: OpaquePointer?
        var results: [WatchVitalsModel] = []

        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Unable to open database")
            return []
        }

        defer { sqlite3_close(db) }

        let query = """
        SELECT timestamp, heart_rate, hrv, motion, respiratory_rate, wrist_temp, oxygen
        FROM watch_vitals
        ORDER BY timestamp DESC
        LIMIT \(limit);
        """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            print("Failed to prepare fetch vitals")
            return []
        }

        defer { sqlite3_finalize(statement) }

        let formatter = ISO8601DateFormatter()

        while sqlite3_step(statement) == SQLITE_ROW {

            let timestampString = String(cString: sqlite3_column_text(statement, 0))
            let timestamp = formatter.date(from: timestampString) ?? Date()

            let data = WatchVitalsModel(
                timestamp: timestamp,
                heartRate: sqlite3_column_double(statement, 1),
                hrv: sqlite3_column_double(statement, 2),
                motion: sqlite3_column_double(statement, 3),
                respiratoryRate: sqlite3_column_double(statement, 4),
                wristTemp: sqlite3_column_double(statement, 5),
                oxygenSaturation: sqlite3_column_double(statement, 6)
            )

            results.append(data)
        }

        print("Fetched \(results.count) vitals from DB")

        return results
    }
}
