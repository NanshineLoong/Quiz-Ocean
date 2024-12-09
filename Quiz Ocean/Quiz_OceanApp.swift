//
//  Quiz_OceanApp.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
// test 

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    return true
  }
}

@main
struct Quiz_OceanApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
//            ContentView()
//                .applyBackground()
//                .onChange(of: scenePhase) { newPhase in
//                    // You may need to handle the inactive phase only.
//                    if newPhase == .inactive || newPhase == .background {
//                        chatStore.save()    // saves conversations and settings
//                        testStore.save()    // save userTests
//                    } else {
//                        // active phase: do nothing
//                    }
//                }
        }
    }
}
