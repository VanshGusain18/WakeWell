import Foundation

struct SleepPreferences: Codable, Equatable {
    let sleepGoalHours: Double
    let bedtimeGoal: Date
    let wakeTimeGoal: Date
}

struct OnboardingPreferences: Codable, Equatable {
    let biologicalSex: String
    let ageRange: String
    let sleepDifficultyTypes: [String]
}

struct PermissionState: Codable, Equatable {
    let healthKitGranted: Bool
    let watchStatus: String
    let notificationsGranted: Bool
}

struct UserProfile: Codable, Equatable {
    let userID: Int
    let authProvider: AuthProvider
    let email: String
    let displayName: String
    let profilePhotoURL: String?
    let memberSince: Date
    let sleepPreferences: SleepPreferences
    let onboardingPreferences: OnboardingPreferences
    let permissionState: PermissionState

    var initials: String {
        let tokens = displayName.split(separator: " ")
        let computed = tokens.prefix(2).compactMap { $0.first }.map(String.init).joined()
        return computed.isEmpty ? "?" : computed
    }
}
