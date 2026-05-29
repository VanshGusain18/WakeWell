//
//  SceneDelegate.swift
//  SetSail
//
//  Created by geu on 30/01/26.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let tabBarLeadingPadding: CGFloat = 16
    private let tabBarItemWidth: CGFloat = 84
    private let tabBarItemSpacing: CGFloat = 8
    private var authObserver: NSObjectProtocol?
    private var alarmObserver: NSObjectProtocol?
    private var riseRitualObserver: NSObjectProtocol?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        authObserver = NotificationCenter.default.addObserver(
            forName: .authStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateRootController(animated: true)
        }

        alarmObserver = NotificationCenter.default.addObserver(
            forName: .setSailOpenAlarmScreen,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.presentPendingAlarm()
        }

        riseRitualObserver = NotificationCenter.default.addObserver(
            forName: .setSailOpenRiseRitual,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.openRiseRitual()
        }

        if window == nil {
            window = UIWindow(windowScene: windowScene)
        }

        updateRootController(animated: false)

        if let notificationResponse = connectionOptions.notificationResponse {
            NotificationManager.shared.handleNotificationResponse(notificationResponse)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        configureTabsAfterLayout()
        presentPendingAlarm()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        configureTabsAfterLayout()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    deinit {
        if let authObserver {
            NotificationCenter.default.removeObserver(authObserver)
        }
        if let alarmObserver {
            NotificationCenter.default.removeObserver(alarmObserver)
        }
        if let riseRitualObserver {
            NotificationCenter.default.removeObserver(riseRitualObserver)
        }
    }

    private func updateRootController(animated: Bool) {
        guard let window else { return }

        let shouldShowMainApp = AuthStateManager.shared.isAuthenticated
        let targetRoot = rootController(forMainApp: shouldShowMainApp)

        if window.rootViewController == nil {
            window.rootViewController = targetRoot
            window.makeKeyAndVisible()
            configureTabsAfterLayout()
            return
        }

        let transitionOptions: UIView.AnimationOptions = animated ? .transitionCrossDissolve : []
        UIView.transition(with: window, duration: animated ? 0.25 : 0.0, options: transitionOptions, animations: {
            window.rootViewController = targetRoot
        }, completion: { _ in
            if shouldShowMainApp {
                self.configureTabsAfterLayout()
            }
        })
    }

    private func rootController(forMainApp: Bool) -> UIViewController {
        if forMainApp {
            return UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() ?? UIViewController()
        }

        return OnboardingContainerTableViewController()
    }

    private func configureTabsAfterLayout() {
        DispatchQueue.main.async { [weak self] in
            self?.insertRiseRitualTabIfNeeded()
            self?.alignTabBarItems()
        }
    }

    private func presentPendingAlarm() {
        guard window?.rootViewController != nil else { return }
        DispatchQueue.main.async {
            AlarmDeepLinkCoordinator.shared.processPendingAlarmIfNeeded()
        }
    }

    private func openRiseRitual() {
        guard AuthStateManager.shared.isAuthenticated else {
            updateRootController(animated: true)
            return
        }

        configureTabsAfterLayout()
        DispatchQueue.main.async { [weak self] in
            guard let tabBarController = self?.window?.rootViewController as? UITabBarController else { return }
            self?.insertRiseRitualTabIfNeeded()
            tabBarController.selectedIndex = min(1, (tabBarController.viewControllers?.count ?? 1) - 1)
        }
    }

    private func insertRiseRitualTabIfNeeded() {
        guard let tabBarController = window?.rootViewController as? UITabBarController,
              let viewControllers = tabBarController.viewControllers,
              viewControllers.count >= 2 else {
            return
        }

        if viewControllers.contains(where: { $0.tabBarItem.title == "Rise Ritual" }) {
            return
        }

        let homeController = viewControllers[0]
        let statsController = viewControllers[1]

        homeController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house.fill"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let riseHost = UIHostingController(rootView: RiseRitualRootView())
        riseHost.title = "Rise Ritual"

        let riseController = UINavigationController(rootViewController: riseHost)
        riseController.setNavigationBarHidden(true, animated: false)
        riseController.navigationBar.prefersLargeTitles = false
        riseController.tabBarItem = UITabBarItem(
            title: "Rise Ritual",
            image: UIImage(systemName: "sparkles"),
            selectedImage: UIImage(systemName: "sparkles")
        )

        statsController.tabBarItem = UITabBarItem(
            title: "Stats",
            image: UIImage(systemName: "chart.bar.fill"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )

        tabBarController.setViewControllers(
            [homeController, riseController, statsController],
            animated: false
        )
    }

    private func alignTabBarItems() {
        guard let tabBarController = window?.rootViewController as? UITabBarController else {
            return
        }

        let tabBar = tabBarController.tabBar
        tabBar.itemPositioning = .fill
        tabBar.layoutIfNeeded()

        let controls = tabBar.subviews
            .compactMap { $0 as? UIControl }
            .sorted { $0.frame.minX < $1.frame.minX }

        guard !controls.isEmpty else { return }

        let maxWidth = tabBar.bounds.width -
            tabBar.safeAreaInsets.left -
            tabBar.safeAreaInsets.right -
            tabBarLeadingPadding * 2
        let width = min(tabBarItemWidth, maxWidth / CGFloat(controls.count))
        let startX = tabBar.safeAreaInsets.left + tabBarLeadingPadding

        for (index, control) in controls.enumerated() {
            var frame = control.frame
            frame.origin.x = startX + CGFloat(index) * (width + tabBarItemSpacing)
            frame.size.width = width
            control.frame = frame
        }
    }

}
