//
//  SignInDaysView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/11/10.
//

import SwiftUI

struct SignInDaysView: View {
    var body: some View {
        VStack {
            Text("Sign-In Days")
            CalendarView(calendar: Calendar.current)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SignInDaysView()
}
