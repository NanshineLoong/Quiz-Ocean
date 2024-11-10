//
//  UserAnswer.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/11/1.
//

import Foundation

struct UserAnswer {
    var question: String
    var answer: String
    var userAnswer: String
    var isCorrect: Bool {
        return answer == userAnswer
    }
    
    init(question: String, answer: String, userAnswer: String) {
        self.question = question
        self.answer = answer
        self.userAnswer = userAnswer
    }
    
    init?(dict: [String: Any]) {
        guard let question = dict["question"] as? String,
              let answer = dict["answer"] as? String,
              let userAnswer = dict["userAnswer"] as? String else {
            return nil
        }
        self.init(question: question, answer: answer, userAnswer: userAnswer)
    }
    
    func toDict() -> [String: Any] {
        return [
            "question": question,
            "answer": answer,
            "userAnswer": userAnswer
        ]
    }
}
