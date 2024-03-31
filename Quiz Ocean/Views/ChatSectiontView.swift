//
//  ContentView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//
import SwiftUI

// Main content view

struct ChatSectionView: View {
    var body: some View {
        NavigationSplitView {
            ChatIndexView()
        } detail: {
            Text("Select a chat.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSectionView()
            .environmentObject(ChatStore.sample)
    }
}
