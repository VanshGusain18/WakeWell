// UserProfileModel.swift
// WakeWell
//
// Stores user profile info collected during onboarding / login.

import Foundation

struct UserProfileModel {
    let id: Int
    let name: String
    let email: String
    let passwordHash: String   // SHA-256 hex of password
    let age: Int
    let gender: String         // "male" / "female" / "other"
    let sleepGoalHours: Double // e.g. 8.0
    let createdAt: Date
}
