//
//  AllTasksView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/12/8.
//
import SwiftUI

struct AllTasksView: View {
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var testStore: TestStore
    @Binding var path: NavigationPath
    
    var body: some View {
        List(taskStore.tasks) { task in
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
        .navigationTitle("All Tasks")
    }
}

