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
    var candidates: [String]?
    var imageUrl: String
    var explanation: String
    var type: String // 题目类型，用字符串代替枚举
    
    enum QuestionType: String {
        case multipleChoice = "multipleChoice"
        case blankFilling = "blankFilling"
    }
    
    // 初始化方法
    init(id: String, content: String, answer: String, candidates: [String]? = nil, imageUrl: String = "", explanation: String = "", type: QuestionType) {
        self.id = id
        self.content = content
        self.answer = answer
        self.candidates = candidates
        self.imageUrl = imageUrl
        self.explanation = explanation
        self.type = type.rawValue
    }
    
    // 从字典初始化对象
    init?(id: String, dict: [String: Any]) {
        guard let content = dict["content"] as? String,
              let answer = dict["answer"] as? String else {
            return nil
        }
        
        self.id = id
        self.content = content
        self.answer = answer
        self.candidates = dict["candidates"] as? [String]
        self.imageUrl = dict["imageUrl"] as? String ?? ""
        self.explanation = dict["explanation"] as? String ?? ""
        self.type = (self.candidates == nil) ? QuestionType.blankFilling.rawValue : QuestionType.multipleChoice.rawValue
    }
    
    // 将对象转换为字典，便于上传到 Firebase
    func toDictionary() -> [String: Any] {
        return [
            "content": content,
            "answer": answer,
            "candidates": candidates ?? [],
            "imageUrl": imageUrl,
            "explanation": explanation,
            "type": type
        ]
    }
    
    
}
