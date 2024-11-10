//
//  ProfileView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/5/13.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var user = UserViewModel()

    var body: some View {
        Button("Logout") {
            user.logout()
        }
    }

}

#Preview {
    ProfileView()
}
