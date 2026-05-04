// DatabaseManager+UserProfile.swift
// WakeWell
//
// Extends DatabaseManager with user_profile table operations.
// Call `DatabaseManager.shared.createUserProfileTable()` once at app start.

import Foundation
import SQLite3
import CryptoKit

extension DatabaseManager {

    // MARK: - Table Creation

    func createUserProfileTable() {
        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else {
            print("Cannot open DB for user_profile table")
            return
        }
        defer { sqlite3_close(db) }

        let sql = """
        CREATE TABLE IF NOT EXISTS user_profile (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            name            TEXT    NOT NULL,
            email           TEXT    NOT NULL UNIQUE,
            password_hash   TEXT    NOT NULL,
            age             INTEGER NOT NULL DEFAULT 0,
            gender          TEXT    NOT NULL DEFAULT 'prefer_not_to_say',
            sleep_goal_hrs  REAL    NOT NULL DEFAULT 8.0,
            created_at      TEXT    NOT NULL
        );
        """

        if sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK {
            print("user_profile table ready")
        } else {
            let err = String(cString: sqlite3_errmsg(db))
            print("user_profile table error:", err)
        }
    }

    // MARK: - Insert / Register

    /// Returns the new row id on success, or nil on failure (e.g. duplicate email).
    @discardableResult
    func insertUserProfile(name: String,
                           email: String,
                           password: String,
                           age: Int,
                           gender: String,
                           sleepGoalHours: Double) -> Int? {

        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else { return nil }
        defer { sqlite3_close(db) }

        let hash = sha256(password)
        let createdAt = ISO8601DateFormatter().string(from: Date())

        let sql = """
        INSERT INTO user_profile
            (name, email, password_hash, age, gender, sleep_goal_hrs, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (name       as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (email      as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 3, (hash       as NSString).utf8String, -1, nil)
        sqlite3_bind_int (stmt, 4, Int32(age))
        sqlite3_bind_text(stmt, 5, (gender     as NSString).utf8String, -1, nil)
        sqlite3_bind_double(stmt, 6, sleepGoalHours)
        sqlite3_bind_text(stmt, 7, (createdAt  as NSString).utf8String, -1, nil)

        if sqlite3_step(stmt) == SQLITE_DONE {
            let rowID = Int(sqlite3_last_insert_rowid(db))
            print("User profile saved, id =", rowID)
            return rowID
        } else {
            let err = String(cString: sqlite3_errmsg(db))
            print("Insert user_profile failed:", err)
            return nil
        }
    }

    // MARK: - Fetch

    func fetchUserProfile() -> UserProfileModel? {
        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else { return nil }
        defer { sqlite3_close(db) }

        let sql = "SELECT id, name, email, password_hash, age, gender, sleep_goal_hrs, created_at FROM user_profile LIMIT 1;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(stmt) }

        if sqlite3_step(stmt) == SQLITE_ROW {
            let id            = Int(sqlite3_column_int(stmt, 0))
            let name          = String(cString: sqlite3_column_text(stmt, 1))
            let email         = String(cString: sqlite3_column_text(stmt, 2))
            let passwordHash  = String(cString: sqlite3_column_text(stmt, 3))
            let age           = Int(sqlite3_column_int(stmt, 4))
            let gender        = String(cString: sqlite3_column_text(stmt, 5))
            let sleepGoal     = sqlite3_column_double(stmt, 6)
            let createdStr    = String(cString: sqlite3_column_text(stmt, 7))
            let createdAt     = ISO8601DateFormatter().date(from: createdStr) ?? Date()

            return UserProfileModel(id: id, name: name, email: email,
                                    passwordHash: passwordHash, age: age,
                                    gender: gender, sleepGoalHours: sleepGoal,
                                    createdAt: createdAt)
        }
        return nil
    }

    // MARK: - Validate Login

    /// Returns `true` if email + password match the stored profile.
    func validateLogin(email: String, password: String) -> Bool {
        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else { return false }
        defer { sqlite3_close(db) }

        let hash = sha256(password)
        let sql  = "SELECT id FROM user_profile WHERE email = ? AND password_hash = ? LIMIT 1;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (email as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (hash  as NSString).utf8String, -1, nil)

        return sqlite3_step(stmt) == SQLITE_ROW
    }

    // MARK: - Update Profile

    func updateUserProfile(name: String, age: Int, gender: String, sleepGoalHours: Double) {
        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else { return }
        defer { sqlite3_close(db) }

        let sql = "UPDATE user_profile SET name = ?, age = ?, gender = ?, sleep_goal_hrs = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
        sqlite3_bind_int (stmt, 2, Int32(age))
        sqlite3_bind_text(stmt, 3, (gender as NSString).utf8String, -1, nil)
        sqlite3_bind_double(stmt, 4, sleepGoalHours)

        sqlite3_step(stmt)
        print("user_profile updated")
    }

    // MARK: - Delete (logout / reset)

    func deleteUserProfile() {
        var db: OpaquePointer?
        guard sqlite3_open(dbURL.path, &db) == SQLITE_OK else { return }
        defer { sqlite3_close(db) }
        sqlite3_exec(db, "DELETE FROM user_profile;", nil, nil, nil)
        print("user_profile cleared")
    }

    // MARK: - Helpers

    private func sha256(_ input: String) -> String {
        let data   = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // Expose dbURL to the extension (mirrors the private computed var in the main file)
    // NOTE: Because dbURL is private in DatabaseManager.swift, rename it to
    // `internal var dbURL` (remove `private`) so this extension can see it.
    // Alternatively, keep it private and move this extension to the same file.
}
