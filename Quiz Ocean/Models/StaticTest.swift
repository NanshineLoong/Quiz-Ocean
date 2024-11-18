//
//  StaticTest.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/11/17.
//

import Foundation

struct StaticTest: Identifiable, Hashable {
    var id: String
    var subject: String
    var level: String
    var year: String
    var paperIndex: String
    var questionIDs: [String] // 存储 question 的 ID 列表
    
    var title: String {
        return "\(subject)-\(level)-\(year)-\(paperIndex)"
    }

    init(id: String, subject: String, level: String, year: String, paperIndex: String, questionIDs: [String]) {
        self.id = id
        self.subject = subject
        self.level = level
        self.year = year
        self.paperIndex = paperIndex
        self.questionIDs = questionIDs
    }
    
    init?(id: String, dict: [String: Any]) {
        guard let subject = dict["subject"] as? String,
                let level = dict["level"] as? String,
                let year = dict["year"] as? String,
                let paperIndex = dict["paperIndex"] as? String,
                let questionIDs = dict["questions"] as? [String] else {
            return nil
        }
        self.init(id: id, subject: subject, level: level, year: year, paperIndex: paperIndex, questionIDs: questionIDs)
    }
    
    
    static func == (lhs: StaticTest, rhs: StaticTest) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
