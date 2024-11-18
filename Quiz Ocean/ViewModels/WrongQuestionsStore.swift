//
//  WrongQuestionsViewModel.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/11/15.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

class WrongQuestionsStore: ObservableObject {
    @Published var wrongQuestions: [WrongQuestionViewModel] = []
    private var ref = Database.root
    private var refHandle: DatabaseHandle?
    
    private func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func setup() {
        guard let uid = getCurrentUserID() else {
            print("Error setting up wrong questions: No user ID found")
            return
        }
        refHandle = ref.child("wrongQuestions/\(uid)").observe(.value) { snapshot in
            var newWrongQuestions = [WrongQuestionViewModel]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let wrongQuestionData = childSnapshot.value as? [String: Any],
                   let wrongQuestion = WrongQuestionViewModel(id: childSnapshot.key, dict: wrongQuestionData) {
                    newWrongQuestions.append(wrongQuestion)
                }
            }
            
            DispatchQueue.main.async {
                self.wrongQuestions = newWrongQuestions
            }
        }
    }
}
