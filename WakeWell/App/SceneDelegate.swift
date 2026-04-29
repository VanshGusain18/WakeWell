// SceneDelegate.swift
// WakeWell
//
// On first launch → OnboardingContainerTableViewController
// On return       → Main tab bar (already logged in)

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let win = UIWindow(windowScene: windowScene)
        win.rootViewController = makeRootViewController()
        window = win
        win.makeKeyAndVisible()
    }

    // MARK: Private

    private func makeRootViewController() -> UIViewController {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "ww_logged_in")

        if isLoggedIn {
            // User already has an account — go straight to main app
            let sb = UIStoryboard(name: "Main", bundle: nil)
            return sb.instantiateInitialViewController()!
        } else {
            // First launch or logged out — show onboarding (no XIB needed)
            return OnboardingContainerTableViewController()
        }
    }

    // MARK: Standard lifecycle stubs

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
