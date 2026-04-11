//
//  MainTabBarController.swift
//  WakeWell
//
//  Created by geu on 11/04/26.
//


// MainTabBarController.swift
import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        styleTabBar()
    }

    private func setupTabs() {
        // ✅ Replace each VC below with your actual screen classes
        let home   = makeNav(vc: HomeViewController(),
                             title: "Home",
                             icon: "house.fill")

        let alarm  = makeNav(vc: AlarmOptionViewController(),
                             title: "Alarm",
                             icon: "bell.fill")

        let rise   = makeNav(vc: ActivityDeckViewController(),
                             title: "Rise",
                             icon: "sunrise.fill")

        let sound  = makeNav(vc: SoundTableViewController(),
                             title: "Sound",
                             icon: "waveform")

        let stats  = makeNav(vc: StatsTableViewController(),
                             title: "Stats",
                             icon: "chart.bar.fill")

        viewControllers = [home, alarm, rise, sound, stats]
        selectedIndex = 0   // opens on Home tab
    }

    private func makeNav(vc: UIViewController,
                         title: String,
                         icon: String) -> UINavigationController {
        vc.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: icon)
        )
        return UINavigationController(rootViewController: vc)
    }

    private func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        // Selected item — Sunrise yellow
        appearance.stackedLayoutAppearance.selected.iconColor    = UIColor(hex: "#F5C842")
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(hex: "#F5C842")
        ]

        // Unselected item — Vessel gray
        appearance.stackedLayoutAppearance.normal.iconColor    = UIColor(hex: "#8A9BB0")
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(hex: "#8A9BB0")
        ]

        tabBar.standardAppearance   = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = UIColor(hex: "#F5C842")
    }
}
