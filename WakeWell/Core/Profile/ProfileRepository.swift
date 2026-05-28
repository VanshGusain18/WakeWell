import Foundation

final class ProfileRepository {

    static let shared = ProfileRepository()

    private init() {}

    func currentProfile() -> UserProfile? {
        guard let session = AuthStateManager.shared.currentSession ?? AuthStateManager.shared.restoreSession() else {
            return nil
        }
        return profile(for: session.userID)
    }

    func profile(for userID: Int) -> UserProfile? {
        guard let model = DatabaseManager.shared.fetchUserProfile(id: userID) else { return nil }
        return map(model: model)
    }

    func profile(forEmail email: String) -> UserProfile? {
        guard let model = DatabaseManager.shared.fetchUserProfile(email: email) else { return nil }
        return map(model: model)
    }

    func signIn(model: UserProfileModel) {
        UserDefaults.standard.set(model.wakeUpGoalTime, forKey: "wakewell.savedAlarmTime")
        AlarmManager.shared.setAlarm(AlarmModel(time: model.wakeUpGoalTime))

        let session = UserSession(
            userID: model.id,
            authProvider: model.authProvider,
            email: model.email,
            displayName: model.displayName,
            profilePhotoURL: model.profilePhotoURL,
            memberSince: model.createdAt
        )
        AuthStateManager.shared.signIn(session)
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "wakewell.savedAlarmTime")
        AuthStateManager.shared.signOut()
    }

    private func map(model: UserProfileModel) -> UserProfile {
        UserProfile(
            userID: model.id,
            authProvider: model.authProvider,
            email: model.email,
            displayName: model.displayName,
            profilePhotoURL: model.profilePhotoURL,
            memberSince: model.createdAt,
            sleepPreferences: SleepPreferences(
                sleepGoalHours: model.sleepGoalHours,
                bedtimeGoal: model.bedtimeGoal,
                wakeTimeGoal: model.wakeTimeGoal
            ),
            onboardingPreferences: OnboardingPreferences(
                biologicalSex: model.biologicalSex,
                ageRange: model.ageRange,
                sleepDifficultyTypes: model.sleepDifficultyTypes
            ),
            permissionState: PermissionState(
                healthKitGranted: model.healthKitPermissionGranted,
                watchStatus: model.watchStatus,
                notificationsGranted: model.notificationPermissionGranted
            )
        )
    }
}
