//
//  WrongQuestionViewModel.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/11/15.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

class WrongQuestionViewModel: ObservableObject, Identifiable {
    var id: String
    var userAnswer: UserAnswer
    var finishedDate: Date
    var reviewedDates: [Date]
    
    private var ref = Database.root
    
    init(id: String, userAnswer: UserAnswer, finishedDate: Date, reviewedDates: [Date]) {
        self.id = id
        self.userAnswer = userAnswer
        self.finishedDate = finishedDate
        self.reviewedDates = reviewedDates
    }
    
    convenience init?(id: String, dict: [String: Any]) {
        guard let userAnswerDict = dict["userAnswer"] as? [String: Any],
                let userAnswer = UserAnswer(dict: userAnswerDict),
                let finishedDate = dict["finishedDate"] as? Date,
              let reviewedDates = dict["reviewedDates"] as? [Date] else {
            return nil
        }
        self.init(id: id, userAnswer: userAnswer, finishedDate: finishedDate, reviewedDates: reviewedDates)
        
    }
    
}
