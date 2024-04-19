//
//  Quiz_OceanApp.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//
// Hello!
// yx

import SwiftUI

@main
struct Quiz_OceanApp: App {
    @StateObject private var chatStore = ChatStore()
    @StateObject private var testStore = TestStore(userId: UUID())
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationTabView()
                .environmentObject(chatStore)
                .environmentObject(testStore)
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
