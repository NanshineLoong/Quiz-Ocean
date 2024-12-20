//
//  TaskViewModel.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/11/15.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class TaskViewModel: ObservableObject, Identifiable {
    var id: String
    var subject: String
    var level: String
    var testYear: String
    var paperIndex: String
    
    var date: Date  // scheduled date
    
    var title: String?
    
    private var ref = Database.root
    
    init(id: String, subject: String, level: String, testYear: String, paperIndex: String, date: Date, title: String?=nil) {
        self.id = id
        self.subject = subject
        self.level = level
        self.testYear = testYear
        self.paperIndex = paperIndex
        self.date = date
        self.title = title ?? subject
    }
    
    // only provide a date to initialize a task
    convenience init(date: Date, title: String) {
        self.init(id: UUID().uuidString, subject: "", level: "", testYear: "", paperIndex: "", date: date, title: title)
        
    }
    
    convenience init?(id: String, dict: [String: Any]) {
        guard let subject = dict["subject"] as? String,
                let level = dict["level"] as? String,
                let testYear = dict["testYear"] as? String,
                let paperIndex = dict["paperIndex"] as? String,
              let timestamp = dict["date"] as? Double else {
            return nil
        }
        let date = Date(timeIntervalSince1970: timestamp)
        self.init(id: id, subject: subject, level: level, testYear: testYear, paperIndex: paperIndex, date: date)
    }
    
}

