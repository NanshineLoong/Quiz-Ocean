//
//  HomeView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var testStore: TestStore
    
    private var subjects: [String] = [
        "Number Sense",
        "General Mathematics",
        "Calculator Applications",
        "General Science"
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var showingFinishedSection = true
    @State private var showingStaredSection = true
    @State private var showingScheduledSection = true
    
    @State private var showingTestSet = false
    
    @State private var path: [String] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            if testStore.isLoading {
                ProgressView("Loading...")
            } else {
                VStack {
                    HeaderView()
                }
                ScrollView {
                    //                CalendarView(calendar: Calendar(identifier: .gregorian))
                    
                    VStack(spacing: 20) {
                        // temporary button for upload test
//                        Button("Upload Test") {
//                            testStore.uploadLocalTests()
//                        }
                        HStack {
                            TextButtonView(label: "Random")
                            TextButtonView(label: "Wrong Question")
                        }
                        .padding(.vertical)
                        
                        ForEach(subjects, id: \.self) { subject in
                            TestCategoryView(subject: subject, tests: testStore.getRandomTestsForSubject(subject), path: $path)
                        }
                    }
                    
                }
            }
        }
    }
}

struct HeaderView: View {
    @EnvironmentObject var userAttribute: UserAttributeViewModel
    
    @State private var showSignInSheet = false
    @State private var showShopSheet = false
    @State private var showHealthSheet = false
    @State private var showLevelSheet = false
    
    var body: some View {
        HStack {
            // 签到天数按钮
            Button(action: {
                showSignInSheet.toggle()
            }) {
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.red)
                    Text("\(userAttribute.days)")
                }
            }
            .sheet(isPresented: $showSignInSheet) {
                SignInDaysView()
            }
            
            Spacer()
            
            // 商城按钮
            Button(action: {
                showShopSheet.toggle()
            }) {
                HStack {
                    Image(systemName: "diamond.tophalf.filled")
                        .foregroundColor(.blue)
                    Text("\(userAttribute.gems)")
                }
            }
            .sheet(isPresented: $showShopSheet) {
                ShopView()
            }
            
            Spacer()
            
            // 生命值按钮
            Button(action: {
                showHealthSheet.toggle()
            }) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(userAttribute.hearts)")
                }
            }
            .sheet(isPresented: $showHealthSheet) {
                HealthView()
            }
            
            Spacer()
            
            // 经验等级按钮
            Button(action: {
                showLevelSheet.toggle()
            }) {
                HStack {
                    Image(systemName: "person.fill")
                    Text("\(userAttribute.levels)")
                }
            }
            .sheet(isPresented: $showLevelSheet) {
                LevelView()
            }
        }
    }
}

struct TextButtonView: View {
    var label: String
    
    var body: some View {
        Button(action: {}) {
            Text(label)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
        .padding(.horizontal)
    }
}


struct TestCategoryView: View {
    let subject: String
    var tests: [TestViewModel]
    @Binding var path: [String]
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text(subject)
                    .font(.headline)
                Spacer()
                // 将NavigationLink设为 Button
                Button {
                    path.append("TestsFromSubjectView")
                } label: {
                    Image(systemName: "arrow.right")
                }
            }
            .padding(.horizontal)
            
            HStack {
                ForEach(tests) { test in
                    TestBoard(test: test, path: $path)
                }
            }
            
            Button("Load another batch") {
                 // 动作
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .shadow(radius: 5)
        .navigationDestination(for: String.self) { destination in
            if destination == "TestsFromSubjectView" {
                TestsFromSubjectView(subject: subject, path: $path)
            }
        }
    }
}

