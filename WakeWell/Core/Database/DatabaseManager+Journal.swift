import Foundation
import SQLite3

struct DailyJournalEntry {
    let date: Date
    let groggyValue: Float
    let morningNote: String
    let isLocked: Bool
    let updatedAt: Date
}

enum DailyJournalDatabaseError: LocalizedError {
    case databaseOpenFailed
    case tableCreationFailed(String)
    case prepareFailed(String)
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .databaseOpenFailed:
            return "Unable to open the database."
        case .tableCreationFailed(let message):
            return "Unable to prepare the journal store: \(message)"
        case .prepareFailed(let message):
            return "Unable to prepare the journal request: \(message)"
        case .saveFailed(let message):
            return "Could not save your daily journal: \(message)"
        }
    }
}

extension DatabaseManager {

    func createDailyJournalTable() {
        _ = ensureDailyJournalTable()
    }

    @discardableResult
    func saveDailyJournal(groggyValue: Float? = nil,
                          morningNote: String? = nil,
                          locked: Bool = false,
                          for date: Date = Date()) -> Result<Void, DailyJournalDatabaseError> {
        switch ensureDailyJournalTable() {
        case .success:
            break
        case .failure(let error):
            return .failure(error)
        }

        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else {
            return .failure(.databaseOpenFailed)
        }
        defer { sqlite3_close(db) }

        let key = Self.dailyJournalDateFormatter.string(from: date)
        let existing = fetchDailyJournalEntry(for: date, db: db)
        let updatedAt = Date()

        let nextGroggy = groggyValue ?? existing?.groggyValue ?? 0
        let nextNote = morningNote ?? existing?.morningNote ?? ""
        let nextLocked = locked || (existing?.isLocked ?? false)

        let sql = """
        INSERT INTO daily_journal_entries (entry_date, groggy_value, morning_note, is_locked, updated_at)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(entry_date) DO UPDATE SET
            groggy_value = excluded.groggy_value,
            morning_note = excluded.morning_note,
            is_locked = excluded.is_locked,
            updated_at = excluded.updated_at;
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let err = String(cString: sqlite3_errmsg(db))
            return .failure(.prepareFailed(err))
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (key as NSString).utf8String, -1, nil)
        sqlite3_bind_double(stmt, 2, Double(nextGroggy))
        sqlite3_bind_text(stmt, 3, (nextNote as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 4, nextLocked ? 1 : 0)

        let updatedAtString = ISO8601DateFormatter().string(from: updatedAt)
        sqlite3_bind_text(stmt, 5, (updatedAtString as NSString).utf8String, -1, nil)

        guard sqlite3_step(stmt) == SQLITE_DONE else {
            let err = String(cString: sqlite3_errmsg(db))
            return .failure(.saveFailed(err))
        }

        return .success(())
    }

    func fetchDailyJournalEntry(for date: Date = Date()) -> DailyJournalEntry? {
        switch ensureDailyJournalTable() {
        case .success:
            break
        case .failure(let error):
            print(error.localizedDescription)
            return nil
        }

        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else { return nil }
        defer { sqlite3_close(db) }
        return fetchDailyJournalEntry(for: date, db: db)
    }

    func fetchLatestDailyJournalEntry() -> DailyJournalEntry? {
        switch ensureDailyJournalTable() {
        case .success:
            break
        case .failure(let error):
            print(error.localizedDescription)
            return nil
        }

        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else { return nil }
        defer { sqlite3_close(db) }

        let sql = """
        SELECT entry_date, groggy_value, morning_note, is_locked, updated_at
        FROM daily_journal_entries
        ORDER BY updated_at DESC
        LIMIT 1;
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(stmt) }

        return readDailyJournalEntry(from: stmt)
    }

    private func ensureDailyJournalTable() -> Result<Void, DailyJournalDatabaseError> {
        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else {
            return .failure(.databaseOpenFailed)
        }
        defer { sqlite3_close(db) }

        let sql = """
        CREATE TABLE IF NOT EXISTS daily_journal_entries (
            entry_date    TEXT PRIMARY KEY,
            groggy_value  REAL NOT NULL DEFAULT 0,
            morning_note  TEXT NOT NULL DEFAULT '',
            is_locked     INTEGER NOT NULL DEFAULT 0,
            updated_at    TEXT NOT NULL
        );
        """

        guard sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK else {
            let err = String(cString: sqlite3_errmsg(db))
            print("daily_journal_entries table error:", err)
            return .failure(.tableCreationFailed(err))
        }

        ensureDailyJournalColumn(named: "is_locked", type: "INTEGER NOT NULL DEFAULT 0", db: db)

        return .success(())
    }

    private func ensureDailyJournalColumn(named columnName: String, type: String, db: OpaquePointer?) {
        let pragma = "PRAGMA table_info(daily_journal_entries);"
        var statement: OpaquePointer?
        var existingColumns = Set<String>()

        if sqlite3_prepare_v2(db, pragma, -1, &statement, nil) == SQLITE_OK {
            defer { sqlite3_finalize(statement) }

            while sqlite3_step(statement) == SQLITE_ROW {
                if let cString = sqlite3_column_text(statement, 1) {
                    existingColumns.insert(String(cString: cString))
                }
            }
        }

        guard !existingColumns.contains(columnName) else { return }

        let alterQuery = "ALTER TABLE daily_journal_entries ADD COLUMN \(columnName) \(type);"
        if sqlite3_exec(db, alterQuery, nil, nil, nil) == SQLITE_OK {
            print("🛠️ Migrated daily_journal_entries: added \(columnName)")
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print("❌ Failed migration for \(columnName):", errorMsg)
        }
    }

    private func fetchDailyJournalEntry(for date: Date, db: OpaquePointer?) -> DailyJournalEntry? {
        let key = Self.dailyJournalDateFormatter.string(from: date)
        let sql = """
        SELECT entry_date, groggy_value, morning_note, is_locked, updated_at
        FROM daily_journal_entries
        WHERE entry_date = ?
        LIMIT 1;
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (key as NSString).utf8String, -1, nil)
        return readDailyJournalEntry(from: stmt)
    }

    private func readDailyJournalEntry(from statement: OpaquePointer?) -> DailyJournalEntry? {
        guard sqlite3_step(statement) == SQLITE_ROW else { return nil }

        let entryDateString = stringColumn(statement, index: 0)
        let groggyValue = sqlite3_column_double(statement, 1)
        let note = stringColumn(statement, index: 2)
        let isLocked = sqlite3_column_int(statement, 3) == 1
        let updatedAtString = stringColumn(statement, index: 4)

        let entryDate = Self.dailyJournalDateFormatter.date(from: entryDateString) ?? Date()
        let updatedAt = ISO8601DateFormatter().date(from: updatedAtString) ?? Date()

        return DailyJournalEntry(
            date: entryDate,
            groggyValue: Float(groggyValue),
            morningNote: note,
            isLocked: isLocked,
            updatedAt: updatedAt
        )
    }

    private func stringColumn(_ statement: OpaquePointer?, index: Int32) -> String {
        guard let cString = sqlite3_column_text(statement, index) else { return "" }
        return String(cString: cString)
    }

    private static let dailyJournalDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
