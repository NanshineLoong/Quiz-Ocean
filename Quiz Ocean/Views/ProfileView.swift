//
//  ProfileView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/5/13.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showLoginSheet = false
    @State private var showDeleteAccountAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading) {
                    if authManager.authState == .signedIn {
                        Text(authManager.user?.displayName ?? "Name placeholder")
                            .font(.headline)

                        Text(authManager.user?.email ?? "Email placeholder")
                            .font(.subheadline)
                    }
                    else {
                        Text("Sign-in to view data!")
                            .font(.headline)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding()

                Spacer()
                Image("homeScreen")
                    .foregroundStyle(Color(.blue))
                    .padding()
                Spacer()

                HStack {
                    // Show `Sign out` iff user is not anonymous,
                    // otherwise show `Sign-in` to present LoginView() when tapped.
                    Button {
                        if authManager.authState != .signedIn {
                            showLoginSheet = true
                        } else {
                            signOut()
                        }
                    } label: {
                        Text(authManager.authState != .signedIn ? "Sign-in" :"Sign out")
                            .font(.body.bold())
                            .frame(width: 150, height: 45, alignment: .center)
                            .foregroundStyle(Color(.yellow))
                            .background(Color(.blue))
                            .cornerRadius(10)
                    }

                    // Delete Account
                    Button {
                        showDeleteAccountAlert = true
                    } label: {
                        Text("Delete Account")
                            .font(.body.bold())
                            .frame(width: 150, height: 45, alignment: .center)
                            .foregroundStyle(.red)
                            .background(Color(.blue))
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.yellow))
            .navigationTitle("Welcome")

            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
            .confirmationDialog("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Yes, Delete", role: .destructive) {
                    Task {
                        do {
                            try await authManager.deleteUserAccount()
                        }
                        catch AuthErrors.ReauthenticateApple {
                            // AppleID re-authentication failed
                        }
                        catch AuthErrors.RevokeAppleID {
                            // AppleID token revocation failed
                        }
                        catch AuthErrors.ReauthenticateGoogle {
                            // Google re-authentication failed
                        }
                        catch AuthErrors.RevokeGoogle {
                            // Google token revocation failed
                        }
                        catch {
                            // Show generic error message
                        }
                    }
                }
            } message: {
                Text("Deleting account is permanent. Are you sure you want to delete your account?")
            }
        }
    }

    func signOut() {
        Task {
            do {
                try await authManager.signOut()
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthManager())
    }
}
