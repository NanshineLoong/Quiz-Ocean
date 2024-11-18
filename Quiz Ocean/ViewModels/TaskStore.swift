//
//  TaskStore.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/11/15.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

class TaskStore: ObservableObject {
    @Published var tasks: [TaskViewModel] = []
    @Published var isLoading = true
    
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
        refHandle = ref.child("tasks/\(uid)").observe(.value) { snapshot in
            var newTasks = [TaskViewModel]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let taskData = childSnapshot.value as? [String: Any],
                   let task = TaskViewModel(id: childSnapshot.key, dict: taskData) {
                    newTasks.append(task)
                }
            }
            
            DispatchQueue.main.async {
                self.tasks = newTasks
                self.isLoading = false
            }
        }
    }
    
    func updateTask(subject: String, level: String, testYear: String, paperIndex: String, date: Date) {
        guard let uid = getCurrentUserID() else { return }
        let newTaskRef = ref.child("tasks/\(uid)").childByAutoId()
        let taskData: [String: Any] = [
            "subject": subject,
            "level": level,
            "testYear": testYear,
            "paperIndex": paperIndex,
            "date": date.timeIntervalSince1970
        ]
        
        newTaskRef.setValue(taskData) { error, _ in
            if let error = error {
                print("Failed to add task: \(error.localizedDescription)")
            } else {
                print("Task added successfully")
            }
        }
    }
    
}
