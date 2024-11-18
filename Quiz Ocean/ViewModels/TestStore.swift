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
    @Published var tests = [StaticTest]()
    @Published var isLoading = true
    
    private var ref = Database.root
    private var refHandle: DatabaseHandle?
    
    private func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func setup() {
        // Set up a listener for changes at the "tests" child path
        refHandle = ref.child("static-test").observe(.value) { snapshot in
            var newTests = [StaticTest]()
            
            // Iterate through each child of the snapshot to create Test objects
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let testData = childSnapshot.value as? [String: Any],
                   let test = StaticTest(id: childSnapshot.key, dict: testData) {
                    newTests.append(test)
                }
            }
//            print(newTests.count)
            
            // Update the published tests property
            DispatchQueue.main.async {
                self.tests = newTests
                self.isLoading = false
            }
        }
    }
    
    func getStaticTest(subject: String, level: String, year: String, paperIndex: String) -> StaticTest? {
        return tests.first { test in
            test.subject == subject &&
            test.level == level &&
            test.year == year &&
            test.paperIndex == paperIndex
        }
    }
    
    func getYears(for subject: String?) -> [String] {
        guard let subject = subject else { return [] }
        return Array(Set(tests.filter { $0.subject == subject }.map { $0.year })).sorted()
    }
    
    func getPaperIndices(subject: String, level: String, year: String) -> [String] {
        return tests
            .filter { $0.subject == subject && $0.level == level && $0.year == year }
            .map { $0.paperIndex }
            .sorted()
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
                let questionRef = ref.child("question").childByAutoId()
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
                let testRef = self.ref.child("static-test").childByAutoId()
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
    
    func isTestFinished(testID: String, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        ref.child("userTests/\(uid)/\(testID)").observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
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
    func filterTestsFromSubject(from subject: String) -> [StaticTest] {
        tests.filter {$0.subject == subject}
    }
    
}
