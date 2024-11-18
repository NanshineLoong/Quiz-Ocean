//
//  HomeView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var wrongQStore: WrongQuestionsStore
    
    @State private var path: [AnyHashable] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            Button(action: {
                testStore.uploadLocalTests()
            }) {
                Text("Upload Local Tests")
            }
            ScrollView {
                VStack {
                    HeaderView()
                }
                
                // My Tasks
                TaskListView()
                
                // Choose a Test
                ChooseTestView()
            }
        }
    }
}

struct HeaderView: View {
    @EnvironmentObject var userAttribute: UserAttributeViewModel
    @State private var greeting: String = ""
    
    var body: some View {
        VStack {
            Text("Hi, \(userAttribute.userName)!")
                .font(.title2)
            Spacer()
            Text(greeting)
                .font(.largeTitle)
        }
        .padding()
        .onAppear {
            updateGreeting()
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            greeting = "Good morning"
        case 12..<18:
            greeting = "Good afternoon"
        default:
            greeting = "Good evening"
        }
    }
}


struct TaskListView: View {
    @EnvironmentObject var testStore: TestStore
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var wrongQStore: WrongQuestionsStore
    @State private var reviewQuestions: [WrongQuestionViewModel] = []
    
    var body: some View {
        if taskStore.isLoading {
            EmptyView()
        } else {
            VStack {
                // Header with title and navigation button
                HStack {
                    Text("My Tasks")
                        .font(.headline)
                    
                    Spacer()
                    
                    NavigationLink(destination: AllTasksView()) {
                        Text("more")
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                Divider()
                
                // Task List
                ScrollView {
                    VStack(spacing: 10) {
                        if !reviewQuestions.isEmpty {
                            NavigationLink(
                                destination: FullTestView(
                                    test: TestViewModel(
                                        questionIDs: reviewQuestions.map { $0.id }
                                    ),
                                    testTitle: "Review Questions"
                                )
                            ) {
                                TaskRowView(
                                    taskTitle: "Review Wrong Questions (\(reviewQuestions.count) for today)",
                                    taskDate: Date()
                                )
                            }
                        }
                        
                        ForEach(todayTasks()) { task in
                            if let staticTest = testStore.getStaticTest(
                                subject: task.subject,
                                level: task.level,
                                year: task.testYear,
                                paperIndex: task.paperIndex
                            ) {
                                NavigationLink(
                                    destination: FullTestView(
                                        test: TestViewModel(
                                            questionIDs: staticTest.questionIDs,
                                            testId: staticTest.id
                                        ),
                                        testTitle: "Test for \(task.subject)"
                                    )
                                ) {
                                    TaskRowView(taskTitle: task.title, taskDate: task.date)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
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
    let taskTitle: String
    let taskDate: Date
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: taskDate)
    }
    
    private var dateColor: Color {
        let calendar = Calendar.current
        if calendar.isDateInToday(taskDate) {
            return .green
        } else if taskDate < Date() {
            return .red
        } else {
            return .gray
        }
    }
    
    var body: some View {
        HStack {
            Text(taskTitle)
                .font(.body)
            
            Spacer()
            
            Text(formattedDate)
                .foregroundColor(dateColor)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}


struct AllTasksView: View {
    @EnvironmentObject var taskStore: TaskStore
    
    var body: some View {
        List(taskStore.tasks) { task in
            TaskRowView(taskTitle: task.title, taskDate: task.date)
        }
        .navigationTitle("All Tasks")
    }
}


struct ChooseTestView: View {
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var testStore: TestStore
    @State private var selectedSubject: String?
    @State private var selectedYear: String?
    @State private var selectedLevel: String?
    @State private var selectedPaperIndex: String?
    
    @State private var isTaskExisting: Bool = false
    @State private var isTestFinished: Bool = false
    @State private var showSheet: Bool = false
    @State private var selectedDate: Date = Date()
    
    @State private var isNavigating = false
    
    @State private var path: [AnyHashable] = []
    
    private let subjects = ["Number Sense", "General Mathematics", "General Science", "Calculator Applications"]
    private let levels = ["Middle"]
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Text("Choose a Test")
                    .font(.largeTitle)
                    .padding()
                
                Divider()
                
                // Subject Selection
                HStack {
                    Text("Subject:")
                    Spacer()
                    ForEach(subjects, id: \.self) { subject in
                        Button(action: {
                            selectedSubject = subject
                            resetSelections()
                        }) {
                            Text(subject)
                                .padding()
                                .background(selectedSubject == subject ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                
                Divider().padding(.vertical)
                
                // Year and Level Selection
                HStack {
                    VStack {
                        Text("Year:")
                        Picker("Year", selection: $selectedYear) {
                            Text("Select Year").tag(nil as String?)
                            ForEach(testStore.getYears(for: selectedSubject), id: \.self) { year in
                                Text(year).tag(year as String?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Level:")
                        Picker("Level", selection: $selectedLevel) {
                            Text("Select Level").tag(nil as String?)
                            ForEach(levels, id: \.self) { level in
                                Text(level).tag(level as String?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Divider().padding(.vertical)
                
                // PaperIndex Selection
                if let subject = selectedSubject, let year = selectedYear, let level = selectedLevel {
                    VStack {
                        Text("Paper Index:")
                        Picker("Paper Index", selection: $selectedPaperIndex) {
                            Text("Select Index").tag(nil as String?)
                            ForEach(testStore.getPaperIndices(subject: subject, level: level, year: year), id: \.self) { index in
                                Text(index).tag(index as String?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Spacer()
                
                // Buttons
                HStack {
                    Button("Create a Task") {
                        showSheet.toggle()
                    }
                    .disabled(isTaskExisting || isTestFinished || !isTestFullySelected())
                    .buttonStyle(.borderedProminent)
                    
                    Button(isTestFinished ? "View Test" : "Start Test") {
                        guard !isNavigating else { return }
                        isNavigating = true
                        guard let subject = selectedSubject,
                              let year = selectedYear,
                              let level = selectedLevel,
                              let index = selectedPaperIndex,
                              let staticTest = testStore.getStaticTest(subject: subject, level: level, year: year, paperIndex: index) else { return }
                        if !path.contains(staticTest) { // 确保路径中没有重复的 staticTest
                            path.append(staticTest)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isNavigating = false
                        }
                    }
                    .disabled(!isTestFullySelected())
                    .buttonStyle(.bordered)
                }
                
            }
            .navigationDestination(for: StaticTest.self) { staticTest in
                FullTestView(
                    test: TestViewModel(questionIDs: staticTest.questionIDs, testId: staticTest.id),
                    testTitle: staticTest.title
                )
            }
            .padding()
            .onChange(of: selectedPaperIndex) { _ in
                fetchStaticTestAndCheckStatus()
            }
            .sheet(isPresented: $showSheet) {
                createTaskSheet
            }
        }
    }
    
    private func isTestFullySelected() -> Bool {
        selectedSubject != nil && selectedYear != nil && selectedLevel != nil && selectedPaperIndex != nil
    }
    
    private func fetchStaticTestAndCheckStatus() {
        guard let subject = selectedSubject, let year = selectedYear, let level = selectedLevel, let index = selectedPaperIndex else { return }
        
        if let staticTest = testStore.getStaticTest(subject: subject, level: level, year: year, paperIndex: index) {
            isTaskExisting = taskStore.tasks.contains { $0.subject == subject && $0.level == level && $0.testYear == year && $0.paperIndex == index }
            checkIfTestFinished(testID: staticTest.id)
        }
    }
    
    private func checkIfTestFinished(testID: String) {
        testStore.isTestFinished(testID: testID) { finished in
            DispatchQueue.main.async {
                self.isTestFinished = finished
            }
        }
    }
    
    private func resetSelections() {
        selectedYear = nil
        selectedLevel = nil
        selectedPaperIndex = nil
    }
    
//    private func startTest() {
//        guard let subject = selectedSubject,
//              let year = selectedYear,
//              let level = selectedLevel,
//              let index = selectedPaperIndex,
//              let staticTest = testStore.getStaticTest(subject: subject, level: level, year: year, paperIndex: index) else { return }
//        if !path.contains(staticTest) { // 确保路径中没有重复的 staticTest
//            path.append(staticTest)
//        }
//    }
    
    // Create Task Sheet
    private var createTaskSheet: some View {
        VStack {
            DatePicker("Schedule Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
            
            Button("Confirm") {
                addTask()
                showSheet = false
            }
        }
        .presentationDetents([.medium])
        .padding()
    }
    
    private func addTask() {
        guard let subject = selectedSubject, let year = selectedYear, let level = selectedLevel, let index = selectedPaperIndex else { return }
        
        taskStore.updateTask(subject: subject, level: level, testYear: year, paperIndex: index, date: selectedDate)
    }
}

