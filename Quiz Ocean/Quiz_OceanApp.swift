//
//  Quiz_OceanApp.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//

import SwiftUI

@main
struct Quiz_OceanApp: App {
    @StateObject private var chatStore = ChatStore()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            TabedView()
                .environmentObject(chatStore)
                .onAppear {
                    chatStore.setup()   // loads conversations and settings
                }
                .onChange(of: scenePhase) { newPhase in
                    // You may need to handle the inactive phase only.
                    if newPhase == .inactive || newPhase == .background {
                        chatStore.save()    // saves conversations and settings
                    } else {
                        // active phase: do nothing
                    }
                }
        }
    }
}
