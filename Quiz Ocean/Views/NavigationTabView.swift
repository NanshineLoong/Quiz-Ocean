//
//  NavigationTabView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//

import SwiftUI

struct NavigationTabView: View {

    var body: some View {
        TabView {
            HomeView(calendar: Calendar(identifier: .gregorian))
                .tabItem {
                    Image("home")
                }
            ChatView()
                .tabItem {
                    Image("chat")
                }
        }
        .accentColor(.black)
    }
}

struct NavigationTabView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationTabView()
    }
}

