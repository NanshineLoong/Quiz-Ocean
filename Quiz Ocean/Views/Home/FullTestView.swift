//
//  TestView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/4/16.
//

import SwiftUI

struct FullTestView: View {
    @ObservedObject var test: TestViewModel
    var testTitle: String
    @State private var tempAnswers: [String] = []
    @State private var isDataLoaded: Bool = false
    
    init(test: TestViewModel, testTitle: String) {
        self.test = test
        self.testTitle = testTitle
    }
    
    var body: some View {
        NavigationView {
            VStack{
                if let score = test.score {
                    Text("Score: \(score)")
                        .font(.title2)
                        .padding()
                        .foregroundColor(.green)
                }
                
                List {
                    ForEach(Array(test.questions.enumerated()), id: \.element.id) { index, question in
                        QuestionView(
                            index: index,
                            question: question,
                            userAnswer: test.userAnswers?[index],
                            tempAnswer: $tempAnswers[index]
                        )
                    }
                }
                
                if test.userAnswers == nil {
                    Button(action: {
                        test.submitTest()
                    }) {
                        Text("Submit")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                }
            }
            .navigationTitle(testTitle)
            .onAppear {
                setupTempAnswers()
            }
        }
    }
    
    private func setupTempAnswers() {
        test.fetchData {
            self.tempAnswers = Array(repeating: "", count: test.questions.count)
            self.isDataLoaded = true
        }
    }
    
}

struct QuestionView: View {
    let index: Int
    let question: Question
    let userAnswer: String?
    @Binding var tempAnswer: String

    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(index + 1). \(question.content)")
                .font(.headline)
            
            // 显示图片（如果有）
            if !question.imageUrl.isEmpty {
                AsyncImage(url: URL(string: question.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                } placeholder: {
                    ProgressView()
                }
            }
            
            // 根据题目类型显示不同视图
            switch Question.QuestionType(rawValue: question.type) {
            case .multipleChoice:
                MultipleChoiceView(question: question, selectedAnswer: $tempAnswer, userAnswer: userAnswer)
                
            case .blankFilling:
                BlankFillingView(question: question, userInput: $tempAnswer, userAnswer: userAnswer)
                
            default:
                Text("Unknown Question Type")
                    .foregroundColor(.red)
            }
            
            // 显示对错标记
            if let userAnswer = userAnswer {
                let isCorrect = userAnswer == question.answer
                HStack {
                    Spacer()
                    Text(isCorrect ? "Right" : "Wrong")
                        .foregroundColor(isCorrect ? .green : .red)
                        .bold()
                }
            }
            
            // 下拉显示答案和解释
            DisclosureGroup("Show Answer & Explanation", isExpanded: $isExpanded) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Correct Answer: \(question.answer)")
                        .foregroundColor(.blue)
                    if !question.explanation.isEmpty {
                        Text("Explanation: \(question.explanation)")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct MultipleChoiceView: View {
    let question: Question
    @Binding var selectedAnswer: String
    let userAnswer: String?
    
    var body: some View {
        let shuffledCandidates = question.candidates?.shuffled() ?? []
        
        ForEach(shuffledCandidates, id: \.self) { candidate in
            Button(action: {
                selectedAnswer = candidate
            }) {
                HStack {
                    Text(candidate)
                    Spacer()
                    if let userAnswer = userAnswer {
                        if userAnswer == candidate {
                            Image(systemName: userAnswer == question.answer ? "checkmark.circle" : "xmark.circle")
                                .foregroundColor(userAnswer == question.answer ? .green : .red)
                        }
                    } else if selectedAnswer == candidate {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: selectedAnswer == candidate ? 2 : 0)
                )
            }
        }
    }
}

struct BlankFillingView: View {
    let question: Question
    @Binding var userInput: String
    let userAnswer: String?
    
    var body: some View {
        if let userAnswer = userAnswer {
            Text(userAnswer)
                .foregroundColor(userAnswer == question.answer ? .green : .red)
                .padding()
        } else {
            TextField("Your answer", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
    }
}
