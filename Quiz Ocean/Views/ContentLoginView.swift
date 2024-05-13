//
//  ContentLoginView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/5/13.
//

import SwiftUI

struct ContentLoginView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                if authManager.authState != .signedOut {
                    ProfileView()
                } else {
                    LoginView()
                }
            }
        }
    }
}

struct ContentLoginView_Previews: PreviewProvider {
    static var previews: some View {
//        HomeView()
        ContentLoginView()
            .environmentObject(AuthManager())
    }
}
