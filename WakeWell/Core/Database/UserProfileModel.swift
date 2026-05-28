// UserProfileModel.swift
// SetSail
//
// Stores user profile info collected during onboarding / login.

import Foundation

struct UserProfileInput {
    let authProvider: AuthProvider
    let firstName: String
    let email: String
    let password: String
    let profilePhotoURL: String?
    let wakeUpGoalTime: Date
    let sleepGoalHours: Double
    let biologicalSex: String
    let ageRange: String
    let bedtimeGoal: Date
    let wakeTimeGoal: Date
    let sleepDifficultyTypes: [String]
    let healthKitPermissionGranted: Bool
    let watchStatus: String
    let notificationPermissionGranted: Bool
}

struct UserProfileModel {
    let id: Int
    let authProvider: AuthProvider
    let firstName: String
    let email: String
    let passwordHash: String   // SHA-256 hex of password
    let profilePhotoURL: String?
    let wakeUpGoalTime: Date
    let sleepGoalHours: Double
    let biologicalSex: String
    let ageRange: String
    let bedtimeGoal: Date
    let wakeTimeGoal: Date
    let sleepDifficultyTypes: [String]
    let healthKitPermissionGranted: Bool
    let watchStatus: String
    let notificationPermissionGranted: Bool
    let createdAt: Date

    var name: String { firstName }
    var displayName: String { firstName }
}
