//
//  TestRow.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import SwiftUI

struct TestBoard: View {
    let test: TestViewModel
    @Binding var path: [String]
    @State var userTest: UserTestViewModel? = nil
    @State private var showTestInfo = false
    
    var body: some View {
        TestCard(test: test)
        .onTapGesture {
            test.fetchUserTestID { userTestID in
                if let userTestID = userTestID {
                    UserTestViewModel.fetchUserTest(from: userTestID) { userTest in
                        if let userTest = userTest {
                            self.userTest = userTest
                        }
                    }
                } else {
                    userTest = nil
                }
                showTestInfo.toggle()
            }
        }
        .sheet(isPresented: $showTestInfo) {
            SheetView(test: test, userTest: userTest, path: $path, showTestInfo: $showTestInfo)
        }
    }
}

struct SheetView: View {
    @StateObject var test: TestViewModel
    @State var userTest: UserTestViewModel?
    @Binding var path: [String]
    @Binding var showTestInfo: Bool
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Text("Standard test")
                    .font(.title2)
                    .bold()
                    .padding()
                
                HStack {
                    TestCard(test: test)
                    
                    VStack {
                        Text("Volume: 15")
                        Text("Average Score: 70")
                    }
                }
                .padding()
                
                // Start Test button
                Button("Start Test") {
                    path.append("Test")
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .frame(width: 300, height: 400)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 20)
            .navigationDestination(for: String.self) { str in
                if str == "Test" {
                    FullTestView(test: test, userTest: userTest, path: $path)
                }
            }
        }
        .onAppear {
            test.fetchUserTestID { userTestID in
                if let userTestID = userTestID {
                    UserTestViewModel.fetchUserTest(from: userTestID) { userTest in
                        if let userTest = userTest {
                            self.userTest = userTest
                        }
                    }
                } else {
                    userTest = nil
                }
            }
        }
    }
}

struct TestCard: View {
    let test: TestViewModel
    var body: some View {
        VStack {
            Text("\(test.subject)")
            Text("\(test.level)")
            Text("\(test.year) \(test.paperIndex)")
        }
        .padding()
        .frame(width: 120, height: 160)
        .background(Color.pink.opacity(0.2))
        .cornerRadius(8)
    }
}

