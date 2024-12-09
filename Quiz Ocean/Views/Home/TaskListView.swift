//
//  TaskListView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/12/8.
//
import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var wrongQStore: WrongQuestionsStore
    @State private var reviewQuestions: [WrongQuestionViewModel] = []
    @Binding var path: NavigationPath
    
    var body: some View {
        if taskStore.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        } else {
            VStack {
                // Header with title and navigation button
                HStack {
                    Text("Today's Tasks")
                        .font(.headline)
                    
                    Spacer()
                    
                    NavigationLink(destination: AllTasksView(path: $path)) {
                        Text("all tasks")
                            .padding(8)
                            .cornerRadius(8)
                    }
                }
                
                Divider()
                
                // Task List
                ScrollView {
                    VStack(spacing: 10) {
                        if !reviewQuestions.isEmpty {
                            TaskRowView(
                                test: TestViewModel(
                                    questionIDs: reviewQuestions.map { $0.id },
                                    testTitle: "Review Questions"
                                ),
                                task: TaskViewModel(
                                    date: Date(), title: "Review Wrong Questions"
                                    ),
                                path: $path
                            )
                        }
                        
                        ForEach(todayTasks()) { task in
                            if let staticTest = testStore.getStaticTest(
                                subject: task.subject,
                                level: task.level,
                                year: task.testYear,
                                paperIndex: task.paperIndex
                            ) {
                                TaskRowView(
                                    test: TestViewModel(
                                        questionIDs: staticTest.questionIDs,
                                        testId: staticTest.id,
                                        testTitle: "Test for \(task.subject)"
                                    ),
                                    task: task,
                                    path: $path
                                )
                            }
                        }
                    }
                    .padding()
                }
                
            }
            .padding()
            .onAppear {
                checkReviewTask()
            }
        }
    }
    
    // 筛选出今天的任务
    private func todayTasks() -> [TaskViewModel] {
        let today = Calendar.current.startOfDay(for: Date())
        return taskStore.tasks.filter {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }
    
    // 检查是否需要显示 Review Wrong Questions 任务
    private func checkReviewTask() {
        let today = Calendar.current.startOfDay(for: Date())
        let maxReviewTimes = 3 // 假设最大复习次数为 3 次
        reviewQuestions = wrongQStore.wrongQuestions.filter { question in
            !Calendar.current.isDate(question.finishedDate, inSameDayAs: today) &&
            !question.reviewedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) &&
            question.reviewedDates.count < maxReviewTimes
        }
    }
}


struct TaskRowView: View {
    let test: TestViewModel
    let task: TaskViewModel
    @Binding var path: NavigationPath
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: task.date)
    }
    
    private var dateColor: Color {
        let calendar = Calendar.current
        if calendar.isDateInToday(task.date) {
            return .green
        } else if task.date < Date() {
            return .red
        } else {
            return .gray
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(dateColor)
            }
            Spacer()
            Button("Start") {
                path.append(test)
            }
        }
//        .navigationDestination(for: TestViewModel.self) { test in
//            FullTestView(
//                test: test,
//                path: $path
//            )
//        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    let testStore = TestStore()
    let taskStore = TaskStore()
    let wrongQStore = WrongQuestionsStore()
    @State var path = NavigationPath()
    
    NavigationStack(path: $path) {
        TaskListView(path: $path)
            .onAppear {
                testStore.setup()
                taskStore.setup()
                wrongQStore.setup()
            }
            .environmentObject(taskStore)
            .environmentObject(wrongQStore)
            .environmentObject(testStore)
    }
}
