//
//  NavigationTabView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//

import SwiftUI

struct NavigationTabView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                if authManager.authState != .signedOut {
                    TabView {
                        HomeView()
                            .tabItem {
                                Image("home")
                            }
                        ChatView()
                            .tabItem {
                                Image("chat")
                            }
                        ProfileView()
                            .tabItem{
                                Image("profile")
                            }
                    }
                    .accentColor(.black)
                } else {
                    LoginView()
                }
            }
        }
    }
}

struct NavigationTabView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationTabView()
    }
}

