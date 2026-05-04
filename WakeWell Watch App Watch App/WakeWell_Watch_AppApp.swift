//
//  WakeWell_Watch_AppApp.swift
//  WakeWell Watch App Watch App
//
//  Created by geu on 29/04/26.
//

import SwiftUI
import WatchKit

@main
struct WakeWell_Watch_App_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor(WatchAppDelegate.self) private var appDelegate

    init() {
        _ = WatchConnectivityManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

final class WatchAppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        _ = WatchConnectivityManager.shared
    }

    func applicationDidBecomeActive() {
        _ = WatchConnectivityManager.shared
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("Watch woke in background")
        WatchConnectivityManager.shared.handle(backgroundTasks: backgroundTasks)
    }
}
