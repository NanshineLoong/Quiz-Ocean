//
//  UserViewModel.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/10/29.
//

import SwiftUI
import FirebaseAuth

class UserViewModel: ObservableObject {
    @AppStorage("isSignedIn") var isSignedIn = false
    @Published var email = ""
    @Published var password = ""
    @Published var alert = false
    @Published var alertMessage = ""
    
    
    private func showAlertMessage(message: String) {
        alertMessage = message
        alert.toggle()
    }
    
    func login() {
        // check if all fields are inputted correctly
        if email.isEmpty || password.isEmpty {
            showAlertMessage(message: "Neither email nor password can be empty.")
            return
        }
        // sign in with email and password
        Auth.auth().signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                self.alertMessage = err.localizedDescription
                self.alert.toggle()
            } else {
                self.isSignedIn = true
            }
        }
    }
    
    func signUp() {
        // check if all fields are inputted correctly
        if email.isEmpty || password.isEmpty {
            showAlertMessage(message: "Neither email nor password can be empty.")
            return
        }
        // sign up with email and password
        Auth.auth().createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                self.alertMessage = err.localizedDescription
                self.alert.toggle()
            } else {
                self.login()
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
            email = ""
            password = ""
        } catch {
            print("Error signing out.")
        }
    }
}
