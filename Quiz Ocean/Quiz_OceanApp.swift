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
    
    @StateObject private var chatStore = ChatStore()
    @StateObject private var testStore = TestStore(userid: UUID())
    @StateObject var authManager: AuthManager
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()

        let authManager = AuthManager()
        _authManager = StateObject(wrappedValue: authManager)
    }

    var body: some Scene {
        WindowGroup {
//            ContentLoginView()
//                .environmentObject(authManager)
            
            NavigationTabView()
                .environmentObject(chatStore)
                .environmentObject(testStore)
                .environmentObject(authManager)
                .onAppear {
                    chatStore.setup()   // loads conversations and settings
                    testStore.setup()   // loads tests and userTests
                }
                .onChange(of: scenePhase) { newPhase in
                    // You may need to handle the inactive phase only.
                    if newPhase == .inactive || newPhase == .background {
                        chatStore.save()    // saves conversations and settings
                        testStore.save()    // save userTests
                    } else {
                        // active phase: do nothing
                    }
                }
        }
    }
}
