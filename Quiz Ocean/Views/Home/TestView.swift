//
//  TestView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/4/16.
//

import SwiftUI

struct TestView: View {
    let test: Test
    @Binding var userTest: UserTest?
    @State private var answers: [String]
    
    init(test: Test, userTest: Binding<UserTest?>) {
        self.test = test
        self._userTest = userTest
        if let answers = userTest.wrappedValue?.userAnswers.map({ $0.answer }), !answers.isEmpty {
            self._answers = State(initialValue: answers)
        } else {
            self._answers = State(initialValue: [String](repeating: "", count: test.questions.count))
        }
//        self._answers = State(initialValue: userTest.wrappedValue?.userAnswers.map {$0.answer} ?? Array(repeating: "", count: test.questions.count))
    }
    
    var body: some View {
        List {
            ForEach(Array(test.questions.enumerated()), id: \.element.id) { index, question in
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(index+1). \(question.content)")
                            .padding()
                        
                        Spacer()
                        
                        if userTest?.score == nil {
                            TextField("Your Answer", text: $answers[index])
                                .frame(width: 150)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(userTest?.userAnswers.first(where: {$0.questionid == question.id})?.answer ?? "")
                            Text(userTest?.userAnswers.first(where: {$0.questionid == question.id})?.isCorrect ?? false ? "✔" : "❌")
                                .foregroundColor(userTest?.userAnswers.first(where: {$0.questionid == question.id})?.isCorrect ?? false ? .green : .red)
                        }
                    }
                    
                    if userTest?.score != nil {
                        Text("Correct Answer: \(question.answer)")
                            .padding(.leading)
                    }
                }
            }
            
            if userTest?.score == nil {
                HStack {
                    Spacer()
                    Button("Submit", action: submitAnswers)
                        .padding()
                    Spacer()
                }
            }
        }
    }
    
    func submitAnswers() {
        let userAnswers = zip(test.questions, answers).map { question, answer -> UserAnswer in
            let isCorrect = question.answer == answer
            return UserAnswer(questionid: question.id, answer: answer, isCorrect: isCorrect)
        }
        
        let score = userAnswers.filter {$0.isCorrect}.count
        
        if var existingUserTest = userTest {
            existingUserTest.userAnswers = userAnswers
            existingUserTest.score = score
            userTest = existingUserTest
        } else {
            userTest = UserTest(userid: UUID(), testid: test.id, score: score, userAnswers: userAnswers)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var question = Question(content: "1+1=", answer: "2")
    static var question2 = Question(content: "2+2=", answer: "4")
    static let subject = Subject(firstName: "Number", lastName: "Sense", img: "numbersense")
    static var test = Test(subject: subject, level: .middle, year: "2024", paperIndex: "#13", questions: [question, question2])
    @State static var userTest: UserTest? = nil

    static var previews: some View {
        TestView(test: test, userTest: $userTest)
    }
}
