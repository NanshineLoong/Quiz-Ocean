//
//  UserAttribute.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/10/31.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth

class UserAttributeViewModel: ObservableObject {
    @Published var userName = "Bob" {
        didSet { updateDatabase(key: "userName", value: userName) }
    }
    @Published var days = 0
    @Published var totalDays = 0
    
    @Published var levels = 0 {
        didSet { updateDatabase(key: "levels", value: levels) }
    }
    @Published var gems = 0 {
        didSet { updateDatabase(key: "gems", value: gems) }
    }
    @Published var hearts = 0 {
        didSet { updateDatabase(key: "hearts", value: hearts) }
    }
    
    @Published var signInDates: [String] = []
    
    private var ref = Database.root
    private var refHandle: DatabaseHandle?
    
    private func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func setup() {
        guard let userID = getCurrentUserID() else { return }
        refHandle = ref.child("users/\(userID)").observe(.value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                self.userName = value["userName"] as? String ?? ""
                self.levels = value["levels"] as? Int ?? 0
                self.gems = value["gems"] as? Int ?? 0
                self.hearts = value["hearts"] as? Int ?? 0
                let signInRecords = value["signInRecords"] as? [String] ?? []
                self.signInDates = signInRecords.sorted()
                self.addTodaySignInRecord()
                self.calculateSignInDays()
            }
        }
    }
    
    private func addTodaySignInRecord() {
        guard let userID = getCurrentUserID() else { return }
        
        let today = DateFormatter.standard.string(from: Date())
        
        if !signInDates.contains(today) {
            signInDates.append(today)
            
            // 更新 Firebase 中的签到记录
            ref.child("users/\(userID)/signInRecords").setValue(signInDates) { error, _ in
                if let error = error {
                    print("Error adding today's sign-in record: \(error.localizedDescription)")
                } else {
                    print("Successfully signed in for today: \(today)")
                }
            }
        }
    }

    
    private func calculateSignInDays() {
        let calendar = Calendar.current
        totalDays = signInDates.count
        
        days = 0
        var currentStreak = 0
        var previousDate: Date? = nil
        
        for dayString in signInDates.reversed() {
            if let date = DateFormatter.standard.date(from: dayString) {
                if let previous = previousDate {
                    if calendar.isDate(date, inSameDayAs: previous) {
                        continue
                    }
                    if let dayBefore = calendar.date(byAdding: .day, value: -1, to: previous),
                       calendar.isDate(date, inSameDayAs: dayBefore) {
                        currentStreak += 1
                    } else {
                        break
                    }
                } else {
                    currentStreak = 1
                }
                previousDate = date
            }
        }
        days = currentStreak
    }

    private func updateDatabase(key: String, value: Any) {
        guard let userID = getCurrentUserID() else { return }
        ref.child("users/\(userID)/\(key)").setValue(value) { error, _ in
            if let error = error {
                print("Error updating \(key): \(error.localizedDescription)")
            }
        }
    }
}


extension DateFormatter {
    static let standard: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
