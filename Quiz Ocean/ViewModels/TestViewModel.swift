//
//  Tests.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class TestViewModel: ObservableObject, Identifiable{
    var id: String
    var subject: String
    var level: String
    var year: String
    var paperIndex: String
    var questionIDs: [String] // 存储 question 的 ID 列表
    
    // 存储下载后的具体 Question 对象
    @Published var downloadedQuestions: [Question]?
    private var ref = Database.root
    
    init(id: String, subject: String, level: String, year: String, paperIndex: String, questionIDs: [String]) {
        self.id = id
        self.subject = subject
        self.level = level
        self.year = year
        self.paperIndex = paperIndex
        self.questionIDs = questionIDs
    }
    
    convenience init?(id: String, dict: [String: Any]) {
        guard let subject = dict["subject"] as? String,
              let level = dict["level"] as? String,
              let year = dict["year"] as? String,
              let paperIndex = dict["paperIndex"] as? String,
              let questionIDs = dict["questions"] as? [String] else {
            return nil
        }
        
        self.init(id: id, subject: subject, level: level, year: year, paperIndex: paperIndex, questionIDs: questionIDs)
    }
    
    /// 从 Firebase 下载所有问题，并存储在 downloadedQuestions 中
    func fetchQuestions() {
        var questions = [Question]()
        let totalQuestions = questionIDs.count
        var completedQuestions = 0
        
        for questionID in questionIDs {
            ref.child("questions/\(questionID)").observeSingleEvent(of: .value, with: { snapshot in
                if let value = snapshot.value as? [String: Any],
                   let question = Question(id: questionID, dict: value) {
                    questions.append(question)
                }
                completedQuestions += 1
                if completedQuestions == totalQuestions {
                    DispatchQueue.main.async {
                        self.downloadedQuestions = questions
                    }
                }
            })
        }
//        self.downloadedQuestions = questions // 提问：这样写会有什么问题
        
    }
    
    /// 清除下载的具体问题数据
    func discardQuestions() {
        downloadedQuestions = nil
    }
    
    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func fetchUserTestID(completion: @escaping (String?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(nil)
            return
        }
        ref.child("test-usertest/\(userID)/\(id)").observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? String {
                completion(value)
            } else {
                completion(nil)
            }
        }) { error in
            print("Error fetching user test ID: \(error.localizedDescription)")
            completion(nil)
        }
    }
}
