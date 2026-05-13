// DatabaseManager+UserProfile.swift
// WakeWell
//
// Extends DatabaseManager with user_profile table operations.
// Call `DatabaseManager.shared.createUserProfileTable()` once at app start.

import Foundation
import SQLite3
import CryptoKit

enum UserProfileDatabaseError: LocalizedError {
    case databaseOpenFailed
    case tableCreationFailed(String)
    case prepareFailed(String)
    case duplicateEmail
    case insertFailed(String)
    case updateFailed(String)

    var errorDescription: String? {
        switch self {
        case .databaseOpenFailed:
            return "Unable to open the database."
        case .tableCreationFailed(let message):
            return "Unable to prepare your account store: \(message)"
        case .prepareFailed(let message):
            return "Unable to prepare the database request: \(message)"
        case .duplicateEmail:
            return "An account with this email already exists."
        case .insertFailed(let message):
            return "Could not create your account: \(message)"
        case .updateFailed(let message):
            return "Could not update your profile: \(message)"
        }
    }
}

extension DatabaseManager {

    // MARK: - Table Creation

    func createUserProfileTable() {
        _ = ensureUserProfileTable()
    }

    private func ensureUserProfileTable() -> Result<Void, UserProfileDatabaseError> {
        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else {
            return .failure(.databaseOpenFailed)
        }
        defer { sqlite3_close(db) }

        let sql = """
        CREATE TABLE IF NOT EXISTS user_profile (
            id                          INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name                  TEXT    NOT NULL DEFAULT '',
            name                        TEXT    NOT NULL DEFAULT '',
            email                       TEXT    NOT NULL UNIQUE,
            password_hash               TEXT    NOT NULL,
            wake_up_goal_time           TEXT    NOT NULL DEFAULT '',
            sleep_goal_hrs              REAL    NOT NULL DEFAULT 8.0,
            biological_sex              TEXT    NOT NULL DEFAULT 'prefer_not_to_say',
            age_range                   TEXT    NOT NULL DEFAULT '18-25',
            bedtime_goal                TEXT    NOT NULL DEFAULT '',
            wake_time_goal              TEXT    NOT NULL DEFAULT '',
            sleep_difficulty_types      TEXT    NOT NULL DEFAULT '[]',
            healthkit_permission_granted INTEGER NOT NULL DEFAULT 0,
            watch_status                TEXT    NOT NULL DEFAULT 'unknown',
            notification_permission_granted INTEGER NOT NULL DEFAULT 0,
            created_at                  TEXT    NOT NULL
        );
        """

        guard sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK else {
            let err = String(cString: sqlite3_errmsg(db))
            print("user_profile table error:", err)
            return .failure(.tableCreationFailed(err))
        }

        ensureUserProfileColumn(named: "first_name", type: "TEXT NOT NULL DEFAULT ''", db: db)
        ensureUserProfileColumn(named: "wake_up_goal_time", type: "TEXT NOT NULL DEFAULT ''", db: db)
        ensureUserProfileColumn(named: "biological_sex", type: "TEXT NOT NULL DEFAULT 'prefer_not_to_say'", db: db)
        ensureUserProfileColumn(named: "age_range", type: "TEXT NOT NULL DEFAULT '18-25'", db: db)
        ensureUserProfileColumn(named: "bedtime_goal", type: "TEXT NOT NULL DEFAULT ''", db: db)
        ensureUserProfileColumn(named: "wake_time_goal", type: "TEXT NOT NULL DEFAULT ''", db: db)
        ensureUserProfileColumn(named: "sleep_difficulty_types", type: "TEXT NOT NULL DEFAULT '[]'", db: db)
        ensureUserProfileColumn(named: "healthkit_permission_granted", type: "INTEGER NOT NULL DEFAULT 0", db: db)
        ensureUserProfileColumn(named: "watch_status", type: "TEXT NOT NULL DEFAULT 'unknown'", db: db)
        ensureUserProfileColumn(named: "notification_permission_granted", type: "INTEGER NOT NULL DEFAULT 0", db: db)

        print("user_profile table ready")
        return .success(())
    }

    private func ensureUserProfileColumn(named columnName: String, type: String, db: OpaquePointer?) {
        let pragma = "PRAGMA table_info(user_profile);"
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

        let alterQuery = "ALTER TABLE user_profile ADD COLUMN \(columnName) \(type);"
        if sqlite3_exec(db, alterQuery, nil, nil, nil) == SQLITE_OK {
            print("🛠️ Migrated user_profile: added \(columnName)")
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(db))
            print("❌ Failed migration for user_profile.\(columnName):", errorMsg)
        }
    }

    // MARK: - Insert / Register

    @discardableResult
    func insertUserProfile(_ input: UserProfileInput) -> Result<Int, UserProfileDatabaseError> {
        switch ensureUserProfileTable() {
        case .success:
            break
        case .failure(let error):
            return .failure(error)
        }

        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else { return .failure(.databaseOpenFailed) }
        defer { sqlite3_close(db) }

        let hash = sha256(input.password)
        let createdAt = ISO8601DateFormatter().string(from: Date())
        let wakeUpGoalTime = Self.timeFormatter.string(from: input.wakeUpGoalTime)
        let bedtimeGoal = Self.timeFormatter.string(from: input.bedtimeGoal)
        let wakeTimeGoal = Self.timeFormatter.string(from: input.wakeTimeGoal)
        let difficultyJSON = jsonString(from: input.sleepDifficultyTypes)

        let sql = """
        INSERT INTO user_profile
            (first_name, name, email, password_hash, wake_up_goal_time, sleep_goal_hrs, biological_sex, age_range, bedtime_goal, wake_time_goal, sleep_difficulty_types, healthkit_permission_granted, watch_status, notification_permission_granted, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let err = String(cString: sqlite3_errmsg(db))
            return .failure(.prepareFailed(err))
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (input.firstName as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (input.firstName as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 3, (input.email as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 4, (hash as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 5, (wakeUpGoalTime as NSString).utf8String, -1, nil)
        sqlite3_bind_double(stmt, 6, input.sleepGoalHours)
        sqlite3_bind_text(stmt, 7, (input.biologicalSex as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 8, (input.ageRange as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 9, (bedtimeGoal as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 10, (wakeTimeGoal as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 11, (difficultyJSON as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 12, input.healthKitPermissionGranted ? 1 : 0)
        sqlite3_bind_text(stmt, 13, (input.watchStatus as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 14, input.notificationPermissionGranted ? 1 : 0)
        sqlite3_bind_text(stmt, 15, (createdAt as NSString).utf8String, -1, nil)

        if sqlite3_step(stmt) == SQLITE_DONE {
            let rowID = Int(sqlite3_last_insert_rowid(db))
            print("User profile saved, id =", rowID)
            return .success(rowID)
        }

        let errorCode = sqlite3_errcode(db)
        let err = String(cString: sqlite3_errmsg(db))
        print("Insert user_profile failed:", err)

        if errorCode == SQLITE_CONSTRAINT {
            return .failure(.duplicateEmail)
        }

        return .failure(.insertFailed(err))
    }

    // MARK: - Fetch

    func fetchUserProfile() -> UserProfileModel? {
        switch ensureUserProfileTable() {
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
        SELECT id, first_name, email, password_hash, wake_up_goal_time, sleep_goal_hrs, biological_sex, age_range, bedtime_goal, wake_time_goal, sleep_difficulty_types, healthkit_permission_granted, watch_status, notification_permission_granted, created_at
        FROM user_profile
        ORDER BY id DESC
        LIMIT 1;
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(stmt) }

        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }

        let id = Int(sqlite3_column_int(stmt, 0))
        let firstName = stringColumn(stmt, index: 1)
        let email = stringColumn(stmt, index: 2)
        let passwordHash = stringColumn(stmt, index: 3)
        let wakeUpGoalTime = Self.timeFormatter.date(from: stringColumn(stmt, index: 4)) ?? Date()
        let sleepGoal = sqlite3_column_double(stmt, 5)
        let biologicalSex = stringColumn(stmt, index: 6)
        let ageRange = stringColumn(stmt, index: 7)
        let bedtimeGoal = Self.timeFormatter.date(from: stringColumn(stmt, index: 8)) ?? Date()
        let wakeTimeGoal = Self.timeFormatter.date(from: stringColumn(stmt, index: 9)) ?? Date()
        let sleepDifficultyTypes = jsonArray(from: stringColumn(stmt, index: 10))
        let healthKitGranted = sqlite3_column_int(stmt, 11) == 1
        let watchStatus = stringColumn(stmt, index: 12)
        let notificationGranted = sqlite3_column_int(stmt, 13) == 1
        let createdAt = ISO8601DateFormatter().date(from: stringColumn(stmt, index: 14)) ?? Date()

        return UserProfileModel(
            id: id,
            firstName: firstName,
            email: email,
            passwordHash: passwordHash,
            wakeUpGoalTime: wakeUpGoalTime,
            sleepGoalHours: sleepGoal,
            biologicalSex: biologicalSex,
            ageRange: ageRange,
            bedtimeGoal: bedtimeGoal,
            wakeTimeGoal: wakeTimeGoal,
            sleepDifficultyTypes: sleepDifficultyTypes,
            healthKitPermissionGranted: healthKitGranted,
            watchStatus: watchStatus,
            notificationPermissionGranted: notificationGranted,
            createdAt: createdAt
        )
    }

    // MARK: - Validate Login

    func validateLogin(email: String, password: String) -> Bool {
        switch ensureUserProfileTable() {
        case .success:
            break
        case .failure(let error):
            print(error.localizedDescription)
            return false
        }

        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else { return false }
        defer { sqlite3_close(db) }

        let hash = sha256(password)
        let sql = "SELECT id FROM user_profile WHERE email = ? AND password_hash = ? LIMIT 1;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (email as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (hash as NSString).utf8String, -1, nil)

        return sqlite3_step(stmt) == SQLITE_ROW
    }

    // MARK: - Update Profile

    @discardableResult
    func updateUserProfile(firstName: String,
                           wakeUpGoalTime: Date,
                           sleepGoalHours: Double,
                           biologicalSex: String,
                           ageRange: String,
                           bedtimeGoal: Date,
                           wakeTimeGoal: Date) -> Result<Void, UserProfileDatabaseError> {
        switch ensureUserProfileTable() {
        case .success:
            break
        case .failure(let error):
            return .failure(error)
        }

        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else { return .failure(.databaseOpenFailed) }
        defer { sqlite3_close(db) }

        let boundedSQL = """
        UPDATE user_profile
        SET first_name = ?, name = ?, wake_up_goal_time = ?, sleep_goal_hrs = ?, biological_sex = ?, age_range = ?, bedtime_goal = ?, wake_time_goal = ?
        WHERE id = (
            SELECT id
            FROM user_profile
            ORDER BY id DESC
            LIMIT 1
        );
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, boundedSQL, -1, &stmt, nil) == SQLITE_OK else {
            let err = String(cString: sqlite3_errmsg(db))
            return .failure(.prepareFailed(err))
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (firstName as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (firstName as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 3, (Self.timeFormatter.string(from: wakeUpGoalTime) as NSString).utf8String, -1, nil)
        sqlite3_bind_double(stmt, 4, sleepGoalHours)
        sqlite3_bind_text(stmt, 5, (biologicalSex as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 6, (ageRange as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 7, (Self.timeFormatter.string(from: bedtimeGoal) as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 8, (Self.timeFormatter.string(from: wakeTimeGoal) as NSString).utf8String, -1, nil)

        guard sqlite3_step(stmt) == SQLITE_DONE else {
            let err = String(cString: sqlite3_errmsg(db))
            return .failure(.updateFailed(err))
        }

        print("user_profile updated")
        return .success(())
    }

    // MARK: - Delete (logout / reset)

    func deleteUserProfile() {
        _ = ensureUserProfileTable()

        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else { return }
        defer { sqlite3_close(db) }
        sqlite3_exec(db, "DELETE FROM user_profile;", nil, nil, nil)
        print("user_profile cleared")
    }

    // MARK: - Helpers

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func jsonString(from values: [String]) -> String {
        let data = (try? JSONEncoder().encode(values)) ?? Data("[]".utf8)
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    private func jsonArray(from string: String) -> [String] {
        guard let data = string.data(using: .utf8),
              let values = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return values
    }

    private func stringColumn(_ statement: OpaquePointer?, index: Int32) -> String {
        guard let cString = sqlite3_column_text(statement, index) else { return "" }
        return String(cString: cString)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
