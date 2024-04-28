//
//  Chat.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import Foundation

// One message in a conversation

struct Chat: Identifiable, Codable {
    private(set) var id = UUID()
    let role: String   // role of the speaker: user or assistant
    var content: String
    var usage: [Int]?
    
    var isUser: Bool {
        role == OpenAIChatRole.user.rawValue
    }
    
    var isAssistant: Bool {
        role == OpenAIChatRole.assistant.rawValue
    }
    
}
