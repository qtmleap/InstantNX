//
//  mainApp.swift
//  InstantNX
//
//  Created by devonly on 2024/10/12.
//  Copyright © 2025 QuantumLeap. All rights reserved.
//

import AdSupport
import AppTrackingTransparency
import Firebase
import FirebaseAppCheck
import FirebaseMessaging
import QuantumLeap
import SwiftUI
// MARK: - mainApp

@main
struct mainApp: App {
    // MARK: Internal

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(NXClient())
                .environmentIsFirstLaunch()
        }
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    true
  }

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options _: UIScene.ConnectionOptions,
    ) -> UISceneConfiguration {
        FirebaseApp.configure()
        Logger.configure()
      return true
    }
}
