//
//  ChatView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//

import SwiftUI

// Chat view
struct ChatView: View {
    var body: some View {
        NavigationSplitView {
            ChatIndexView()
        } detail: {
            Text("Select a chat.")
        }
    }
}


struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environmentObject(ChatStore.sample)
    }
}
