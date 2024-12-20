//
//  Tests.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class TestViewModel: ObservableObject, Hashable {
    @Published var questions: [Question] = []
    @Published var userAnswers: [String]
    @Published var score: Int = 0
    @Published var isDataLoaded = false
    @Published var isFinished = false
    
    var testId: String?
    var questionIDs: [String]
    var testTitle: String
    
    private var ref = Database.root
    
    init(questionIDs: [String], testId: String?=nil, testTitle: String="Test") {
        self.questionIDs = questionIDs
        self.testId = testId
        self.testTitle = testTitle
        self.userAnswers = Array(repeating: "", count: questionIDs.count)
    }
    
    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    /// 综合调用 fetchQuestions 和 fetchUserAnswers，并在完成后执行 completion
    func fetchData() {
        // 创建 Dispatch Group
        let dispatchGroup = DispatchGroup()
        
        // 下载问题数据
        dispatchGroup.enter()
        fetchQuestions {
            dispatchGroup.leave()
        }
        
        // 下载用户答案数据
        if let testId = testId {
            dispatchGroup.enter()
            fetchUserAnswers(testId: testId) {
                dispatchGroup.leave()
            }
        }
        
        // 在所有任务完成后设置 isDataLoaded
        dispatchGroup.notify(queue: .main) {
            self.isDataLoaded = true
        }
    }

    /// 从 Firebase 下载用户的答案，并存储在 userAnswers 中
    private func fetchUserAnswers(testId: String, completion: @escaping () -> Void) {
        guard let uid = getCurrentUserID() else {
            print("Error fetching user answers: No user ID found")
            completion()
            return
        }
        ref.child("user-test/\(uid)/\(testId)").observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                self.userAnswers = value["userAnswers"] as? [String] ?? Array(repeating: "", count: self.questionIDs.count)
                self.score = value["score"] as? Int ?? 0
                self.isFinished = true
            }
            completion()
        }
    }

    /// 从 Firebase 下载所有问题，并存储在 questions 中
    private func fetchQuestions(completion: @escaping () -> Void) {
        ref.child("question").getData { error, snapshot in
            guard error == nil else {
                print("Error getting data \(error!)")
                completion()
                return
            }

            if let value = snapshot?.value as? [String: [String: Any]] {
                var questions = [Question]()
                for questionID in self.questionIDs {
                    if let questionDict = value[questionID],
                       let question = Question(id: questionID, dict: questionDict) {
                        questions.append(question)
                    }
                }
                DispatchQueue.main.async {
                    self.questions = questions
                }
            }
            completion()
        }
    }

    
    func submitTest() {
        guard let userID = getCurrentUserID() else {
            print("Error submitting test: No user ID found")
            return
        }
        score = zip(userAnswers, questions).filter { $0.0 == $0.1.answer }.count * 10
        if let testId = testId {
            ref.child("user-test/\(userID)/\(testId)").setValue([
                "userAnswers": userAnswers,
                "score": score
            ])
        }
    }
    
    static func == (lhs: TestViewModel, rhs: TestViewModel) -> Bool {
        return lhs.testId == rhs.testId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(testId)
    }
    
//    func fetchUserTestID(completion: @escaping (String?) -> Void) {
//        guard let userID = getCurrentUserID() else {
//            completion(nil)
//            return
//        }
//        ref.child("user-test/\(userID)/\(testId)").observeSingleEvent(of: .value, with: { snapshot in
//            if let value = snapshot.value as? String {
//                completion(value)
//            } else {
//                completion(nil)
//            }
//        }) { error in
//            print("Error fetching user test ID: \(error.localizedDescription)")
//            completion(nil)
//        }
//    }
}
