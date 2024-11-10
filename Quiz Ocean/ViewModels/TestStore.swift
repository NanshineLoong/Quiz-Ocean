//
//  TestStore.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/4/10.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

class TestStore: ObservableObject {
    @Published var tests = [TestViewModel]()
    @Published var isLoading = true
    
    private var ref = Database.root
    private var refHandle: DatabaseHandle?
    
    private func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func setup() {
        // Set up a listener for changes at the "tests" child path
        refHandle = ref.child("tests").observe(.value) { snapshot in
            var newTests = [TestViewModel]()
            
            // Iterate through each child of the snapshot to create Test objects
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let testData = childSnapshot.value as? [String: Any],
                   let test = TestViewModel(id: childSnapshot.key, dict: testData) {
                    newTests.append(test)
                }
            }
            print(newTests.count)
            
            // Update the published tests property
            DispatchQueue.main.async {
                self.tests = newTests
                self.isLoading = false
            }
        }
    }
    func uploadLocalTests() {
        var testsToUpload = [Dictionary<String, Any>]()
        let filenums = 11
        for i in 0...filenums {
            let filename = "Test\(i)"
            if let loadedtest = loadTestFromBundle(filename: filename) {
                testsToUpload.append(loadedtest)
            } else {
                // Have printed the error message
            }
        }
        
        // Upload questions and tests to Firebase
        for var test in testsToUpload {
            guard let questions = test["questions"] as? [[String: Any]] else {
                print("Questions not found or invalid format in test: \(test)")
                continue
            }
            
            var questionIds = [String]()
            let dispatchGroup = DispatchGroup()
            
            // upload questions
            for question in questions {
                dispatchGroup.enter()
                let questionRef = ref.child("questions").childByAutoId()
                questionRef.setValue(question) { error, ref in
                    if let error = error {
                        print("Failed to upload question: \(error)")
                    } else {
                        if let questionId = ref.key {
                            questionIds.append(questionId)
                        }
                    }
                    dispatchGroup.leave()
                }
            }
            
            // upload test
            dispatchGroup.notify(queue: .main) {
                test["questions"] = questionIds
                let testRef = self.ref.child("tests").childByAutoId()
                testRef.setValue(test) { error, ref in
                    if let error = error {
                        print("Failed to upload test: \(error)")
                    } else {
                        print("Successfully uploaded test with id \(ref.key ?? "unknown")")
                    }
                }
            }
        }
    }
    
    func loadTestFromBundle(filename: String) -> [String: Any]? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Failed to locate \(filename).json in Bundle.")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Successfully loaded \(filename).json from Bundle.")
                return jsonObject
            } else {
                print("Failed to cast JSON data as dictionary for \(filename).json.")
            }
        } catch {
            print("Failed to decode \(filename).json from Bundle.")
        }
        return nil
    }

    deinit {
        // Remove observer when this instance is deallocated
        if let refHandle = refHandle {
            ref.child("tests").removeObserver(withHandle: refHandle)
        }
    }
    
    
    
//    func findUserTestFromTest(from test: TestViewModel) -> UserTestViewModel? {
//        userTests.first { $0.testid == test.id }
//    }
//    
    func filterTestsFromSubject(from subject: String) -> [TestViewModel] {
        tests.filter {$0.subject == subject}
    }
    
    func getRandomTestsForSubject(_ subject: String) -> [TestViewModel] {
        let filteredTests = tests.filter { $0.subject == subject }
        return Array(filteredTests.shuffled().prefix(3))
    }
}
