//
//  NavigationTabView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isSignedIn") var isSignedIn = false
    
//    @StateObject private var chatStore = ChatStore()
    @StateObject private var testStore = TestStore()
    @StateObject private var taskStore = TaskStore()
    @StateObject private var wrongQStore = WrongQuestionsStore()
    @StateObject private var userAttribute = UserAttributeViewModel()

    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            if isSignedIn {
                TabView {
                    HomeView()
                        .tabItem {
                            Image("home")
                        }
                    ProfileView()
                        .tabItem{
                            Image("profile")
                        }
                }
                .background(Color.clear)
                .onAppear {
                    testStore.setup()
                    taskStore.setup()
                    wrongQStore.setup()
                    userAttribute.setup()
                }
                .environmentObject(taskStore)
                .environmentObject(wrongQStore)
                .environmentObject(testStore)
                .environmentObject(userAttribute)
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
