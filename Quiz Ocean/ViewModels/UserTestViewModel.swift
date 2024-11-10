//
//  UserTest.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/11/1.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class UserTestViewModel: ObservableObject {
    @Published var id: String
    @Published var score: Int
    @Published var userAnswers: [UserAnswer]
    
    private var ref = Database.root
    
    init(id: String, score: Int, userAnswers: [UserAnswer]) {
        self.id = id
        self.score = score
        self.userAnswers = userAnswers
    }
    
    // 上传 UserTest 数据
    func uploadUserTest() {
        guard let uid = UserTestViewModel.getCurrentUserID() else {
            print("Error uploading user test: No user ID found")
            return
        }
        ref.child("userTests/\(uid)/\(id)").setValue([
            "score": score,
            "userAnswers": userAnswers.compactMap { $0.toDict() }
        ]) { error, _ in
            if let error = error {
                print("Error uploading user test: \(error.localizedDescription)")
            }
        }
    }
    
    static func didTapSubmitButton(score: Int, userAnswers: [UserAnswer]) {
        if let uid = UserTestViewModel.getCurrentUserID() {
            let ref = Database.root.child("userTests/\(uid)")
            guard let key = ref.childByAutoId().key else {
                print("Error uploading user test: No key found")
                return
            }
            ref.child(key).setValue([
                "score": score,
                "userAnswers": userAnswers.compactMap { $0.toDict() }
            ]) { error, _ in
                if let error = error {
                    print("Error uploading user test: \(error.localizedDescription)")
                }
            }
        }
    }
    
    static private func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    static func fetchUserTest(from id: String, completion: @escaping (UserTestViewModel?) -> Void) {
        guard let uid = self.getCurrentUserID() else {
            print("Error fetching user test: No user ID found")
            completion(nil)
            return
        }
        let ref = Database.root
        ref.child("userTests/\(uid)/\(id)").observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? [String: Any] {
                let score = value["score"] as? Int ?? 0
                let userAnswers = (value["userAnswers"] as? [[String: Any]] ?? []).compactMap { UserAnswer(dict: $0) }
                completion(UserTestViewModel(id: id, score: score, userAnswers: userAnswers))
            } else {
                print("Error fetching user test: No value found")
                completion(nil)
            }
            
        }) { error in
            print("Error fetching user test: \(error.localizedDescription)")
            completion(nil)
        }
    }
}
