import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        HealthKitManager.shared.requestAuthorization { success in
            print("HealthKit Permission:", success)

            if success {
                //HealthKitManager.shared.addMockSleepData()
                HealthKitManager.shared.fetchLastNightSleep()
            }
        }

        
        WatchDebugRunner.run()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
extension AppDelegate: UNUserNotificationCenterDelegate {

    // MARK: - Setup (call from application(_:didFinishLaunchingWithOptions:))

    func setupNotificationCenter() {
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Foreground delivery
    // Shows the notification even while the app is open (needed if alarm fires while app is active)

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler:
                                     @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }

    // MARK: - Action handling

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {

        let actionID = response.actionIdentifier

        switch actionID {

        // ── User tapped "Stop Alarm" or dismissed the notification ──────────
        case "STOP_ALARM", UNNotificationDefaultActionIdentifier:
            // Cancel the sound (if playing via AVAudioSession — see AlarmAudioPlayer below)
            AlarmAudioPlayer.shared.stop()

            // Post a local notification banner nudging the user to open the app
            scheduleOpenAppReminder()

        // ── User tapped "Start Morning Ritual" ──────────────────────────────
        case "START_RITUAL":
            AlarmAudioPlayer.shared.stop()
            // Navigate to the Rise Rituals screen
            navigateToRiseRituals()

        default:
            break
        }

        completionHandler()
    }

    // MARK: - Open-app reminder

    /// Fires a follow-up notification 2 seconds later that deep-links into the Rise tab.
    private func scheduleOpenAppReminder() {
        let content          = UNMutableNotificationContent()
        content.title        = "Good morning! ☀️"
        content.body         = "Ready to start your morning ritual?"
        content.sound        = .default
        content.categoryIdentifier = "WAKEWELL_OPEN_PROMPT"

        // Register the "Start Ritual" action on this category too
        let startAction = UNNotificationAction(
            identifier: "START_RITUAL",
            title:      "▶ Start Morning Ritual",
            options:    [.foreground]
        )
        let promptCategory = UNNotificationCategory(
            identifier:        "WAKEWELL_OPEN_PROMPT",
            actions:           [startAction],
            intentIdentifiers: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([promptCategory])

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "wakewell.open_prompt",
                                            content:    content,
                                            trigger:    trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    // MARK: - Navigation helper

    private func navigateToRiseRituals() {
        DispatchQueue.main.async {
            guard let scene  = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first,
                  let tabBar = window.rootViewController as? UITabBarController else { return }

            // Rise tab is index 2 — adjust if your tab order differs
            tabBar.selectedIndex = 2

            // If the Rise tab is embedded in a nav controller, pop to root
            if let nav = tabBar.selectedViewController as? UINavigationController {
                nav.popToRootViewController(animated: false)
            }
        }
    }
}
import AVFoundation

final class AlarmAudioPlayer {

    static let shared = AlarmAudioPlayer()
    private var player: AVAudioPlayer?

    private init() {}

    func start(soundName: String = "alarm_chime", ext: String = "caf") {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode:    .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession setup error: \(error)")
        }

        guard let url = Bundle.main.url(forResource: soundName, withExtension: ext) else {
            print("Alarm sound file '\(soundName).\(ext)' not found in bundle.")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1   // loop indefinitely
            player?.play()
        } catch {
            print("AVAudioPlayer error: \(error)")
        }
    }

    func stop() {
        player?.stop()
        try? AVAudioSession.sharedInstance().setActive(false,
             options: .notifyOthersOnDeactivation)
    }
}
