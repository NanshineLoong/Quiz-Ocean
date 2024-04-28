//
//  TestStore.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/4/10.
//

import Foundation
import SwiftUI

@MainActor
final class TestStore: ObservableObject {
    var tests = [Test]()
    @Published var userTests = [UserTest]()
    let userid: UUID
    
    #if DEBUG
    static let sample: TestStore = {
        let testStore = TestStore(userid: UUID())
        testStore.tests = [Test.sample]
        return testStore
    }()
    #endif
    
    init(userid: UUID) {
        self.userid = userid
    }
    
    // set up the Test Store data
    //
    // load tests and userTests from files
    func setup() {
        tests.removeAll()
        
        // Tests
        let filenums = 1
        for i in 0...filenums {
            let filename = "Test\(i)"
            if let loadedtest = loadTestFromBundle(filename: filename) {
                tests.append(loadedtest)
            } else {
                // Have printed the error message
            }
        }
        
        // UserTests
        if let loadedUserTests = loadUserTests(userId: self.userid) {
            userTests = loadedUserTests
        } else {
            // Have printed the error message
        }
    }
    
    // save the Test Store data
    //
    // stores userTests into a file
    func save() {
        guard !userTests.isEmpty else { return }
        do {
            let url = getDocumentsDirectory().appendingPathComponent("userTests_\(userid).json")
            let data = try JSONEncoder().encode(userTests)
            try data.write(to: url)
        } catch {
            assertionFailure("Failed to save UserTests.")
        }
    }
    
    func loadTestFromBundle(filename: String) -> Test? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Failed to locate \(filename).json in Bundle.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let test = try decoder.decode(Test.self, from: data)
            print("Successfully load \(filename).json in Bundle.")
            return test
        } catch {
            print("Failed to decode \(filename).json from Bundle.")
        }

        return nil
    }
    
    func loadUserTests(userId: UUID) -> [UserTest]? {
        let fileurl = getDocumentsDirectory().appendingPathComponent("userTests_\(userId).json")
        if let data = try? Data(contentsOf: fileurl) {
            let decoder = JSONDecoder()
            if let loadedUserTests = try? decoder.decode([UserTest].self, from: data) {
                return loadedUserTests
            }
        }
        print("Failed to decode \(userId)'s UserTests.")
        return nil
    }
    
    func saveUserTest(userId: UUID, userTest: UserTest) {
        if let index = userTests.firstIndex(where: {$0.testid == userTest.testid}) {
            userTests[index] = userTest
        } else {
            userTests.append(userTest)
        }
        
        do {
            let fileurl = getDocumentsDirectory().appendingPathComponent("userTests_\(userId).json")
            let data = try JSONEncoder().encode(userTests)
            try data.write(to: fileurl, options: .atomic)
        } catch {
            print(error)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func findUserTestFromTest(from test: Test) -> UserTest? {
        userTests.first { $0.testid == test.id }
    }
    
    func filterTestsFromSubject(from subject: Subject) -> [Test] {
        tests.filter {$0.subject == subject}
    }
    
    func filterStaredTests() -> [Test] {
        tests.filter {findUserTestFromTest(from: $0)?.stared ?? false}
    }
    
    func filterFinishedTests() -> [Test] {
        tests.filter {(findUserTestFromTest(from: $0)?.score != nil)}
    }
    
    func filterScheduledTests() -> [Test] {
        tests.filter { test in
            guard let usertest = findUserTestFromTest(from: test) else {
                return false
            }
            // reture unfinished but scheduled test
            return usertest.score == nil && usertest.scheduledDate != nil
        }
    }
    
    func filterScheduledTests(on date: Date, for calendar: Calendar) -> [Test] {
        tests.filter { test in
            guard let usertest = findUserTestFromTest(from: test), let scheduledDate = usertest.scheduledDate else {
                return false
            }
            return calendar.isDate(date, inSameDayAs: scheduledDate)
        }
    }
    
    func bindingForUserTest(from test: Test) -> Binding<UserTest?> {
        Binding<UserTest?> (
            get: { self.findUserTestFromTest(from: test)},
            set: {newValue in
                if let newValue = newValue {
                    self.saveUserTest(userId: self.userid, userTest: newValue)
                }
            }
        )
    }
}
