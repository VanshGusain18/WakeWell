// AppDelegate.swift  (UPDATED)
// WakeWell

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Create user_profile table if it doesn't exist yet
        DatabaseManager.shared.createUserProfileTable()

        // HealthKit
        HealthKitManager.shared.requestAuthorization { success in
            if success {
                HealthKitManager.shared.fetchLastNightSleep()
            }
        }

        WatchDebugRunner.run()
        WatchDataManager.shared.start()
        AlarmManager.shared.setTestAlarm()
        AlarmManager.shared.loadSavedAlarm()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
