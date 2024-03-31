//
//  TabView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//

import SwiftUI

struct TabedView: View {

    var body: some View {
        TabView {
            HomeSectionView()
                .tabItem {
                    Image(systemName: "house")
                }
            ChatSectionView()
                .tabItem {
                    Image(systemName: "message")
                }
        }
        .accentColor(.black)
    }
}

