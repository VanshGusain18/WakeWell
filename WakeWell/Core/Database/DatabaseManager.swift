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

        print("DB PATH:", dbURL.path)
        
        return dbURL
    }

    func fetchLatestSession() -> SleepSessionModel? {
        ensureSleepSessionsTable()

        var db: OpaquePointer?

        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Unable to open database")
            return nil
        }

        defer { sqlite3_close(db) }

        let query = """
        SELECT id, start_time, end_time, alarm_time, trigger_time, trigger_reason, confidence, created_at
        FROM sleep_sessions
        ORDER BY created_at DESC
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
            let startTime = Date(timeIntervalSince1970: sqlite3_column_double(statement, 1))
            let endTime = sqlite3_column_type(statement, 2) == SQLITE_NULL
                ? nil
                : Date(timeIntervalSince1970: sqlite3_column_double(statement, 2))
            let alarmTime = Date(timeIntervalSince1970: sqlite3_column_double(statement, 3))
            let triggerTime = sqlite3_column_type(statement, 4) == SQLITE_NULL
                ? nil
                : Date(timeIntervalSince1970: sqlite3_column_double(statement, 4))
            let triggerReason = sqlite3_column_type(statement, 5) == SQLITE_NULL
                ? nil
                : String(cString: sqlite3_column_text(statement, 5))
            let confidence = sqlite3_column_type(statement, 6) == SQLITE_NULL
                ? nil
                : sqlite3_column_double(statement, 6)
            let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 7))

            let session = SleepSessionModel(
                id: id,
                startTime: startTime,
                endTime: endTime,
                alarmTime: alarmTime,
                triggerTime: triggerTime,
                triggerReason: triggerReason,
                confidence: confidence,
                createdAt: createdAt
            )

            print("📊 FETCH LATEST SESSION")
            print("- id:", session.id)
            print("- start:", session.startTime)
            print("- trigger:", session.triggerTime as Any)

            return session
        }

        return nil
    }

    @discardableResult
    func createSleepSession(startTime: Date, alarmTime: Date) -> Int? {
        ensureSleepSessionsTable()

        var db: OpaquePointer?

        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Unable to open database")
            return nil
        }

        defer { sqlite3_close(db) }

        let query = """
        INSERT INTO sleep_sessions
        (start_time, end_time, alarm_time, trigger_time, trigger_reason, confidence, created_at)
        VALUES (?, NULL, ?, NULL, NULL, NULL, ?);
        """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            print("Failed to prepare sleep session insert")
            return nil
        }

        defer { sqlite3_finalize(statement) }

        let createdAt = Date().timeIntervalSince1970
        sqlite3_bind_double(statement, 1, startTime.timeIntervalSince1970)
        sqlite3_bind_double(statement, 2, alarmTime.timeIntervalSince1970)
        sqlite3_bind_double(statement, 3, createdAt)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print("❌ SESSION INSERT FAILED:", errorMsg)
            return nil
        }

        let sessionId = Int(sqlite3_last_insert_rowid(db))
        print("💾 SESSION INSERTED")
        print("- sessionId:", sessionId)
        return sessionId
    }

    func completeSleepSession(
        triggerTime: Date,
        reason: String,
        confidence: Double,
        sessionId: Int? = nil
    ) {
        ensureSleepSessionsTable()

        var db: OpaquePointer?

        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Unable to open database")
            return
        }

        defer { sqlite3_close(db) }

        let query: String
        if sessionId != nil {
            query = """
            UPDATE sleep_sessions
            SET end_time = ?, trigger_time = ?, trigger_reason = ?, confidence = ?
            WHERE id = ?;
            """
        } else {
            query = """
            UPDATE sleep_sessions
            SET end_time = ?, trigger_time = ?, trigger_reason = ?, confidence = ?
            WHERE id = (
                SELECT id FROM sleep_sessions
                WHERE end_time IS NULL
                ORDER BY created_at DESC
                LIMIT 1
            );
            """
        }

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            print("Failed to prepare sleep session update")
            return
        }

        defer { sqlite3_finalize(statement) }

        sqlite3_bind_double(statement, 1, triggerTime.timeIntervalSince1970)
        sqlite3_bind_double(statement, 2, triggerTime.timeIntervalSince1970)
        sqlite3_bind_text(statement, 3, (reason as NSString).utf8String, -1, nil)
        sqlite3_bind_double(statement, 4, confidence)

        if let sessionId {
            sqlite3_bind_int(statement, 5, Int32(sessionId))
        }

        guard sqlite3_step(statement) == SQLITE_DONE else {
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print("❌ SESSION UPDATE FAILED:", errorMsg)
            return
        }

        print("✅ SESSION UPDATED IN DB")
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

        let timestampString = formatter.string(from: data.timestamp)
        sqlite3_bind_text(statement, 1, (timestampString as NSString).utf8String, -1, nil)
        sqlite3_bind_double(statement, 2, data.heartRate)
        sqlite3_bind_double(statement, 3, data.hrv)
        sqlite3_bind_double(statement, 4, data.motion)
        sqlite3_bind_double(statement, 5, data.respiratoryRate)
        sqlite3_bind_double(statement, 6, data.wristTemp ?? 0)
        sqlite3_bind_double(statement, 7, data.oxygenSaturation ?? 0)

        if sqlite3_step(statement) == SQLITE_DONE {
            print("✅ INSERT SUCCESS at:", data.timestamp)
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print("❌ INSERT FAILED:", errorMsg)
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

//        print("Fetched \(results.count) vitals from DB")

        return results
    }
    
    func clearVitals() {
        var db: OpaquePointer?

        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Failed to open DB for clearing")
            return
        }

        defer { sqlite3_close(db) }

        // 1. Delete all rows
        sqlite3_exec(db, "DELETE FROM watch_vitals;", nil, nil, nil)

        // 2. Reset AUTOINCREMENT counter
        sqlite3_exec(db, "DELETE FROM sqlite_sequence WHERE name='watch_vitals';", nil, nil, nil)

        print("🧹 Vitals cleared + ID reset")
    }

    private func ensureSleepSessionsTable() {
        var db: OpaquePointer?

        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Unable to open database")
            return
        }

        defer { sqlite3_close(db) }

        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS sleep_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            start_time DOUBLE,
            end_time DOUBLE,
            alarm_time DOUBLE,
            trigger_time DOUBLE,
            trigger_reason TEXT,
            confidence REAL,
            created_at DOUBLE
        );
        """

        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print("Failed to ensure sleep_sessions table:", errorMsg)
        }
    }
}
