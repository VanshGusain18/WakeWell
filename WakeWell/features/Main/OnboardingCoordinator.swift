//
//  OnboardingCoordinator.swift
//  WakeWell
//
//  Created by geu on 11/04/26.
//

// OnboardingCoordinator.swift
import UIKit

class OnboardingCoordinator {
    static let hasSeenOnboardingKey = "hasSeenOnboarding"

    static func rootViewController() -> UIViewController {
        if UserDefaults.standard.bool(forKey: hasSeenOnboardingKey) {
            // User has already onboarded → go straight to Tab Bar
            return MainTabBarController()
        } else {
            // First launch → show Splash → Onboarding
            return SplashViewController()
        }
    }

    // Call this when the user finishes all detail screens
    static func completeOnboarding(from vc: UIViewController) {
        UserDefaults.standard.set(true, forKey: hasSeenOnboardingKey)

        let tabBar = MainTabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        tabBar.modalTransitionStyle = .crossDissolve
        vc.present(tabBar, animated: true)
    }
}
