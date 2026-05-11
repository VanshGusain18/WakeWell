//
//  SceneDelegate.swift
//  WakeWell
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


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        configureTabsAfterLayout()
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

    private func configureTabsAfterLayout() {
        DispatchQueue.main.async { [weak self] in
            self?.insertRiseRitualTabIfNeeded()
            self?.alignTabBarItems()
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
