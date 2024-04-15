//
//  Tests.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import Foundation

struct Subject: Hashable, Codable {
    let firstName: String
    let lastName: String
    let img: String
    
    init(firstName: String, lastName: String, img: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.img = img
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let subjectString = try container.decode(String.self)
        
        let mappings = [
            "Number Sense": "numbersense",
            "General Mathematics": "mathematics",
            "Calculator Application": "calculator",
            "General Science": "science"
        ]
        
        guard let img = mappings[subjectString] else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Subject string does not match any known subjects")
        }
        
        let components = subjectString.split(separator: " ").map(String.init)
        guard components.count == 2 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected subject string to contain exactly two words")
        }
        
        self.init(firstName: components[0], lastName: components[1], img: img)
    }
}

struct Test: Codable, Hashable, Identifiable {
    enum Level: String, Codable {
        case middle = "Middle School" // middle school
        case high = "High School" // high school
    }
    
    private(set) var id = UUID()
    let subject: Subject
    let level: Level
    let year: String
    let paperIndex: String
    
    var questions: [Question]
    
    #if DEBUG
    static let sample: Test = {
        var test = Test(subject: Subject(firstName: "Number", lastName: "Sense", img: "numbersense"),level: .middle, year: "2022", paperIndex: "#13", questions: [Question(id: UUID(), content: "1+1=", answer: "2")])
        return test
    }()
    #endif
}

struct Question: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var content: String
    var answer: String
}

struct UserAnswer: Codable, Identifiable {
    var id = UUID()
    var questionID: UUID
    var userAnswer: String
    var isCorrect: Bool
}

struct UserTest: Codable, Identifiable {
    var id = UUID()
    var testId: UUID
    
    var scheduledDate: Date?
    var stared: Bool
    var score: Int?
    var userAnswers: [UserAnswer]
    
    
    init(testId: UUID, scheduledDate: Date? = nil, stared: Bool = false, score: Int? = nil, userAnswers: [UserAnswer] = []) {
        self.testId = testId
        self.scheduledDate = scheduledDate
        self.stared = stared
        self.score = score
        self.userAnswers = userAnswers
    }
}
