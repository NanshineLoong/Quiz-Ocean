//
//  Question.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/11/1.
//
import Foundation

struct Question: Identifiable {
    var id: String
    var content: String
    var answer: String

    init(id: String, content: String, answer: String) {
        self.id = id
        self.content = content
        self.answer = answer
    }
    
    init?(id: String, dict: [String: Any]) {
        guard let content = dict["content"] as? String,
              let answer = dict["answer"] as? String else {
            return nil
        }
        self.init(id: id, content: content, answer: answer)
    }
}
