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
    
    var fullName: String {
            "\(firstName) \(lastName)"
        }
    
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
    
    private(set) var id: UUID
    let subject: Subject
    let level: Level
    let year: String
    let paperIndex: String
    
    var questions: [Question]
    
    #if DEBUG
    static let sample: Test = {
        var test = Test(subject: Subject(firstName: "Number", lastName: "Sense", img: "numbersense"),level: .middle, year: "2022", paperIndex: "#13", questions: [Question(content: "1+1=", answer: "2")])
        return test
    }()
    #endif
    
    init(subject: Subject, level: Level, year: String, paperIndex: String, questions: [Question]) {
        self.subject = subject
        self.level = level
        self.year = year
        self.paperIndex = paperIndex
        self.questions = questions
        
        self.id = UUID(uuid: "\(subject.firstName)\(subject.lastName)\(level.rawValue)\(year)\(paperIndex)".hashUUID())
    }
    
    enum CodingKeys: String, CodingKey {
        case subject, level, year, paperIndex, questions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let subject = try container.decode(Subject.self, forKey: .subject)
        let level = try container.decode(Test.Level.self, forKey: .level)
        let year = try container.decode(String.self, forKey: .year)
        let paperIndex = try container.decode(String.self, forKey: .paperIndex)
        let questions = try container.decode([Question].self, forKey: .questions)
        
        self.init(subject: subject, level: level, year: year, paperIndex: paperIndex, questions: questions)
    }
}

struct Question: Codable, Identifiable, Hashable {
    var id: UUID
    var content: String
    var answer: String
    
    enum CodingKeys: String, CodingKey {
        case content,answer
    }
    init(content: String, answer: String) {
        self.content = content
        self.answer = answer
        // 直接用content的哈希值生成 UUID
        self.id = UUID(uuid: content.hashUUID())
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let content = try container.decode(String.self, forKey: .content)
        let answer = try container.decode(String.self, forKey: .answer)
        
        self.init(content: content, answer: answer)
    }
    
    
}

struct UserAnswer: Codable {
    var questionid: UUID
    var answer: String
    var isCorrect: Bool
    
    init(questionid: UUID, answer: String, isCorrect: Bool) {
        self.questionid = questionid
        self.answer = answer
        self.isCorrect = isCorrect
    }
}

struct UserTest: Codable {
    var userid: UUID
    var testid: UUID
    
    var scheduledDate: Date?
    var stared: Bool
    var score: Int?
    var userAnswers: [UserAnswer]
    
    
    init(userid: UUID, testid: UUID, scheduledDate: Date? = nil, stared: Bool = false, score: Int? = nil, userAnswers: [UserAnswer] = []) {
        self.userid = userid
        self.testid = testid
        self.scheduledDate = scheduledDate
        self.stared = stared
        self.score = score
        self.userAnswers = userAnswers
    }
}

extension String {
    func hashUUID() -> uuid_t {
        let hashValue = self.hash
        let bytes = withUnsafeBytes(of: hashValue) { (pointer: UnsafeRawBufferPointer) -> [UInt8] in
            Array(pointer.bindMemory(to: UInt8.self))
        }
        // 扩展或截断数组以确保总共有16个字节
        let extended = bytes + Array(repeating: 0, count: max(0, 16 - bytes.count))
        let truncated = Array(extended.prefix(16))
        return (truncated[0], truncated[1], truncated[2], truncated[3],
                truncated[4], truncated[5], truncated[6], truncated[7],
                truncated[8], truncated[9], truncated[10], truncated[11],
                truncated[12], truncated[13], truncated[14], truncated[15])
    }
}
