//
//  TestView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/4/16.
//

import SwiftUI

struct FullTestView: View {
    @ObservedObject var test: TestViewModel
    @Binding var path: NavigationPath
    
    init(test: TestViewModel, path: Binding<NavigationPath>) {
        self.test = test
        self._path = path
        self.test.fetchData()
    }
    
    var body: some View {
        if !test.isDataLoaded {
            ProgressView()
        } else {
            ScrollView {
                if test.isFinished {
                    Text("Score: \(test.score)")
                        .font(.title2)
                        .padding()
                        .foregroundColor(.green)
                }

                VStack {
                    ForEach(Array(test.questions.enumerated()), id: \.element.id) { index, question in
                        QuestionView(
                            index: index,
                            question: question,
                            userAnswer: $test.userAnswers[index],
                            isFinished: test.isFinished
                        )
                    }
                }
                
                if !test.isFinished {
                    Button(action: {
                        test.submitTest()
                        path.removeLast()
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
            .navigationTitle(test.testTitle)
        }
    }
}

struct QuestionView: View {
    let index: Int
    let question: Question
    @Binding var userAnswer: String
    let isFinished: Bool

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
                MultipleChoiceView(question: question, selectedAnswer: $userAnswer, isFinished: isFinished)
                
            case .blankFilling:
                BlankFillingView(question: question, userInput: $userAnswer, isFinished: isFinished)
                
            default:
                Text("Unknown Question Type")
                    .foregroundColor(.red)
            }
            
            // 显示对错标记
            if isFinished {
                let isCorrect = userAnswer == question.answer
                HStack {
                    Spacer()
                    Text(isCorrect ? "Right" : "Wrong")
                        .foregroundColor(isCorrect ? .green : .red)
                        .bold()
                }
                
                // 下拉显示答案和解释
                DisclosureGroup("", isExpanded: $isExpanded) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Answer: \(question.answer)")
                            .foregroundColor(.blue)
                        if !question.explanation.isEmpty {
                            Text("Explanation: \(question.explanation)")
                                .foregroundColor(.gray)
                        }
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
    let isFinished: Bool
    
    var body: some View {
        let candidates = question.candidates ?? []
        
        ForEach(candidates, id: \.self) { candidate in
            Button(action: {
                if !isFinished {
                    selectedAnswer = candidate
                }
            }) {
                HStack {
                    Text(candidate)
                    Spacer()
                    if isFinished && selectedAnswer == candidate  {
                        Image(systemName: selectedAnswer == question.answer ? "checkmark.circle" : "xmark.circle")
                            .foregroundColor(selectedAnswer == question.answer ? .green : .red)
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
    let isFinished: Bool
    
    var body: some View {
        if isFinished {
            Text(userInput)
                .foregroundColor(userInput == question.answer ? .green : .red)
                .padding()
        } else {
            TextField("Your answer", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
    }
}
