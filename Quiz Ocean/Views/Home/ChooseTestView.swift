//
//  ChooseTestView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/12/8.
//

import SwiftUI

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
    @State private var showAlert = false
    @State private var alertToShow: Alert?
    
    @State private var isNavigating = false
    
    @Binding var path: NavigationPath
    
    private let subjects = [
        ("Number Sense", "123.rectangle"),
        ("General Mathematics", "function"),
        ("General Science", "atom"),
        ("Calculator Applications", "plus.slash.minus")
    ]
    private let levels = ["Middle"]
    
    var body: some View {
        VStack {
            HStack {
                Text("Start a Test")
                    .font(.headline)
                Spacer()
            }

            Divider()
            
            VStack {
                // Subject Selection
                Text("Subject")
                    .font(.headline)
                HStack (spacing: 16) {
                    ForEach(subjects, id: \.0) { subject, iconName in
                        VStack {
                            Button(action: {
                                selectedSubject = subject
                                resetSelections()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(selectedSubject == subject ? Color.blue.opacity(0.8) : Color.gray.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    Image(systemName: iconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                }
                            }
                            Text(subject.split(separator: " ").map { String($0.first!) }.joined()).font(.caption)
                        }
                    }
                }
                
                Divider()
                        .padding(.vertical)
                
                // Year, Level, Index Selection
                HStack (spacing: 16) {
                    VStack {
                        Text("Year")
                            .font(.headline)
                        Picker("Year", selection: $selectedYear) {
                            Text("Year").tag(nil as String?)
                            ForEach(testStore.getYears(for: selectedSubject), id: \.self) { year in
                                Text(year).tag(year as String?)
                            }
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Level")
                            .font(.headline)
                        Picker("Level", selection: $selectedLevel) {
                            Text("Level").tag(nil as String?)
                            ForEach(levels, id: \.self) { level in
                                Text(level).tag(level as String?)
                            }
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Index")
                            .font(.headline)
                        Picker("Paper Index", selection: $selectedPaperIndex) {
                            Text("Index").tag(nil as String?)
                                
                            ForEach(testStore.getPaperIndices(subject: selectedSubject, level: selectedLevel, year: selectedYear), id: \.self) { index in
                                Text(index).tag(index as String?)
                            }
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Divider()
                        .padding(.vertical)
                
                // Buttons
                HStack (spacing: 8) {
                    Spacer()
                    Button("Create Task") {
                        if isTaskExisting {
                            showTaskAlert()
                        } else {
                            showSheet.toggle()
                        }
                    }
                    .disabled(!isTestFullySelected())
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    
                    Button("Start Test") {
                        if isTestFinished {
                            showTestFinishedAlert()
                        } else {
                            guard let subject = selectedSubject,
                                  let year = selectedYear,
                                  let level = selectedLevel,
                                  let index = selectedPaperIndex,
                                  let staticTest = testStore.getStaticTest(subject: subject, level: level, year: year, paperIndex: index) else { return }
                            resetSelections()
                            path.append(staticTest)
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .frame(maxWidth: .infinity)
                    .disabled(!isTestFullySelected())
                    
                    
                    Button("View Test") {
                        guard let subject = selectedSubject,
                              let year = selectedYear,
                              let level = selectedLevel,
                              let index = selectedPaperIndex,
                              let staticTest = testStore.getStaticTest(subject: subject, level: level, year: year, paperIndex: index) else { return }
                        path.append(staticTest)
                    }
                    .disabled(!isTestFullySelected() || !isTestFinished)
                    .buttonStyle(.bordered)
                    
                    Spacer()
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding()
        .onChange(of: selectedPaperIndex) { _ in
            fetchStaticTestAndCheckStatus()
        }
        .sheet(isPresented: $showSheet) {
            createTaskSheet
        }
        .alert(isPresented: $showAlert) {
            alertToShow!
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
    
    private func showTestFinishedAlert() {
        let alert = Alert(
            title: Text("Test Already Finished"),
            message: Text("This test has already been completed. Do you want to restart it?"),
            primaryButton: .default(Text("Restart"), action: {
                guard let subject = selectedSubject,
                      let year = selectedYear,
                      let level = selectedLevel,
                      let index = selectedPaperIndex,
                      let staticTest = testStore.getStaticTest(subject: subject, level: level, year: year, paperIndex: index) else { return }
                path.append(staticTest)
            }),
            secondaryButton: .cancel(Text("Cancel"))
        )
        alertToShow = alert
        showAlert.toggle()
    }
    
    private func showTaskAlert() {
        guard let subject = selectedSubject, let year = selectedYear, let level = selectedLevel, let index = selectedPaperIndex else { return }
        
        let existingTask = taskStore.tasks.first {
            $0.subject == subject && $0.level == level && $0.testYear == year && $0.paperIndex == index
        }
        guard let task = existingTask else { return }
        
        let alert = Alert(
            title: Text("Task Already Exists"),
            message: Text("Task Details:\nSubject: \(task.subject)\nLevel: \(task.level)\nYear: \(task.testYear)\nPaper Index: \(task.paperIndex)\nDate: \(task.date.formatted(.dateTime.month().day().year()))"),
            primaryButton: .default(Text("Edit Task"), action: { showSheet.toggle() }),
            secondaryButton: .cancel(Text("Cancel"))
        )
        alertToShow = alert
        showAlert.toggle()
    }
    
    private func addTask() {
        guard let subject = selectedSubject, let year = selectedYear, let level = selectedLevel, let index = selectedPaperIndex else { return }
        
        if isTaskExisting {
            let existingTask = taskStore.tasks.first {
                $0.subject == subject && $0.level == level && $0.testYear == year && $0.paperIndex == index
            }
            taskStore.updateTask(task: existingTask!, date: selectedDate)
        } else {
            taskStore.addTask(subject: subject, level: level, testYear: year, paperIndex: index, date: selectedDate)
        }
    }
}


#Preview {
    let testStore = TestStore()
    let taskStore = TaskStore()
    @State var path = NavigationPath()
    
    ChooseTestView(path: $path)
        .onAppear {
            testStore.setup()
            taskStore.setup()
        }
        .environmentObject(taskStore)
        .environmentObject(testStore)
}
