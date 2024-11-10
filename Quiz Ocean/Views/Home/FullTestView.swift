//
//  TestView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/4/16.
//

import SwiftUI

struct FullTestView: View {
    @ObservedObject var test: TestViewModel
    @State var userTest: UserTestViewModel?
    @State private var answers: [String]
    @Binding var path: [String]
    @State private var isTimeout = false
    
    init(test: TestViewModel, userTest: UserTestViewModel?, path: Binding<[String]>) {
        self._test = ObservedObject(wrappedValue: test)
        self.userTest = userTest
        if let answers = userTest?.userAnswers.compactMap({ $0.answer }), !answers.isEmpty {
            self._answers = State(initialValue: answers)
        } else {
            self._answers = State(initialValue: [String](repeating: "", count: test.questionIDs.count))
        }
        self._path = path
    }
    
    var body: some View {
        if isTimeout {
            // 导入到一个空页面
            VStack {
                Text("Failed to load questions.")
                Button("Back") {
                    path.removeLast() // 返回到上一个页面
                }
                .padding()
            }
        } else {
            List {
                if userTest?.score != nil {
                    ForEach(Array(userTest!.userAnswers.enumerated()), id: \.offset) { (index, userAnswer)in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(index+1). \(userAnswer.question)")
                                Spacer()
                                Text(userAnswer.answer)
                                Text(userAnswer.isCorrect ? "✔" : "❌")
                                    .foregroundColor(userAnswer.isCorrect ? .green : .red)
                            }
                        }
                    }
                } else if test.downloadedQuestions != nil {
                    ForEach(Array(test.downloadedQuestions!.enumerated()), id: \.offset) { (index, userAnswer)in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(index+1). \(userAnswer.content)")
                                Spacer()
                                TextField("Your Answer", text: $answers[index])
                                    .frame(width: 150)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        Button("Submit", action: submitAnswers)
                            .padding()
                        Spacer()
                    }
                } else {
                    ProgressView("Loading questions...")
                        .onAppear {
                            test.fetchQuestions()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { // 设置超时时间，例如 10 秒
                                if test.downloadedQuestions == nil {
                                    isTimeout = true // 标记为超时
                                }
                            }
                        }
                }
            }
        }
    }
    
    private func submitAnswers() {
        let userAnswers: [UserAnswer] = zip(test.downloadedQuestions!, answers).map { (question, userAnswer) in
            return UserAnswer(question: question.content, answer: question.answer, userAnswer: userAnswer)
        }
        
        let score = userAnswers.filter {$0.isCorrect}.count * 100 / test.downloadedQuestions!.count
        
        if let existingUserTest = userTest {
            existingUserTest.userAnswers = userAnswers
            existingUserTest.score = score
            userTest = existingUserTest
            userTest!.uploadUserTest()
        } else {
            UserTestViewModel.didTapSubmitButton(score: score, userAnswers: userAnswers)
            path.removeLast()
        }
    }
}
